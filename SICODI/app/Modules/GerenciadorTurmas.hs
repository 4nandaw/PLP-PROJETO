{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorTurmas where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)

data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

data AlunoTurma = AlunoTurma {
    nota1 :: Float,
    nota2 :: Float,
    nota3 :: Float,
    faltas :: Int
} deriving (Generic, Show)

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String
} deriving (Generic, Show)

instance ToJSON Turma
instance ToJSON AlunoTurma

instance FromJSON AlunoTurma
instance FromJSON Aluno

listarTurmas :: String -> IO String
listarTurmas disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    createDirectoryIfMissing True $ takeDirectory diretorio

    listaDeTurmas <- getDirectoryContents diretorio

    let response = mapM_ (\x -> (ajustarExibirTurmas x disciplina)) listaDeTurmas

    unlines $ response

ajustarExibirTurmas :: String -> String -> IO String
ajustarExibirTurmas turma disciplina = do
    if turma /= "." && turma /= ".." then do
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/alunos/"

        createDirectoryIfMissing True $ takeDirectory diretorio

        listaDeAlunos <- getDirectoryContents diretorio
        let numAlunos = (length listaDeAlunos) - 2

        return (turma ++ " ------ " ++ (show numAlunos) ++ " aluno(s)")
    else return ""

verAlunos :: String -> IO()
verAlunos diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    mapM_ (\x -> exibirAluno x diretorio) listaDeAlunos

exibirAluno :: String -> String -> IO()
exibirAluno matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioInfo = "./db/alunos/" ++ matricula
        let diretorioA = diretorio ++ matricula

        aluno <- B.readFile diretorioInfo
        alunoFaltas <- B.readFile diretorioA

        nome <- case decode aluno of 
            Just (Aluno nome _ _ ) -> return $ nome

        matriculaDecode <- case decode aluno of 
            Just (Aluno _ matricula _ ) -> return $ matricula

        faltas <- case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ faltas) -> return $ faltas

        putStrLn (matriculaDecode ++ " - " ++ nome ++ " ----- " ++ (show faltas) ++ " falta(s)")
    else putStr ""

criarTurma :: String -> IO()
criarTurma disciplina = do
    putStrLn "CADASTRO DE TURMA"
    putStrLn "Nome da turma: "
    nome <- getLine
    putStrLn "Codigo da turma: "
    codigo <- getLine

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        createDirectoryIfMissing True $ takeDirectory diretorio

        let dados = encode (Turma {nome = nome, codigo = codigo, alunos = []})
        B.writeFile diretorio dados
        putStrLn "Cadastro concluído!"
        putStrLn " "

    else print "Erro: Codigo de turma ja esta em uso"

excluirAluno :: String -> IO()
excluirAluno disciplina = do
    putStrLn "Informe o codigo da turma: "
    codigo <- getLine

    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then putStrLn "Turma invalida"
    else do
        putStrLn "Informe a matricula do aluno: "
        matricula <- getLine

        let diretorioAluno = ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matricula ++ ".json")

        validarExistenciaAluno <- doesFileExist diretorioAluno

        if not validarExistenciaAluno then putStrLn "Aluno nao esta na turma ou nao existe"
        else do
            removeFile diretorioAluno
            putStrLn "Aluno removido!"


excluirTurma :: String -> IO()
excluirTurma disciplina = do
    putStrLn "Informe o codigo da turma a ser excluida: "
    codigo <- getLine

    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then putStrLn "Turma invalida"
    else do
        removeDirectoryRecursive ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo)
        putStrLn "Turma removida!"

solicitarEAlocarAluno :: String -> IO()
solicitarEAlocarAluno disciplina = do
    putStrLn "Informe o codigo da turma: "
    codigo <- getLine

    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then putStrLn "Codigo invalido!"
    else do
        putStrLn "Forneca um valor em branco para finalizar"
        putStrLn "Informe o proximo aluno (matricula): "
        m <- getLine
        alocarAluno m disciplina codigo

alocarAluno :: String -> String -> String -> IO()
alocarAluno matricula disciplina codigo = do

    if matricula == "" then putStrLn "Registro finalizado!"
    else do
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matricula ++ ".json"

        validarMatricula <- doesFileExist ("./db/alunos/" ++ matricula ++ ".json")

        if not validarMatricula then putStrLn "Matricula invalida"
        else do
            createDirectoryIfMissing True $ takeDirectory diretorio

            let dados = encode (AlunoTurma {faltas = 0, nota1 = 0.0, nota2 = 0.0, nota3 = 0.0})

            B.writeFile diretorio dados

        putStrLn "Informe o proximo aluno (matricula): "
        m <- getLine
        alocarAluno m disciplina codigo