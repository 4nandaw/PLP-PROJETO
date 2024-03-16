{-# LANGUAGE DeriveGeneric #-}

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
    notas :: [Float],
    faltas :: Int
} deriving (Generic, Show)

instance ToJSON Turma
instance ToJSON AlunoTurma

escolherOpcaoTurma :: String -> IO()
escolherOpcaoTurma disciplina = do
    escolha <- getLine
    escolherOpcaoMenuTurmas escolha disciplina
    if (escolha /= "0") then opcoesDeTurmas disciplina
    else putStrLn " "

opcoesDeTurmas :: String -> IO()
opcoesDeTurmas disciplina = do
    putStrLn "MENU DE TURMAS ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Minhas turmas"
    putStrLn "[2] Criar turma"
    putStrLn "[3] Adicionar aluno"
    putStrLn "[4] Excluir aluno"
    putStrLn "[5] Excluir turma"
    putStrLn "===================="
    escolherOpcaoTurma disciplina

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = putStrLn "Lista"
        | (escolha == "2") = criarTurma disciplina
        | (escolha == "3") = solicitarEAlocarAluno disciplina
        | (escolha == "4") = excluirAluno disciplina
        | (escolha == "5") = excluirTurma disciplina
        | otherwise = putStrLn "Opção Inválida!!"

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

            let dados = encode (AlunoTurma {faltas = 0, notas = []})

            B.writeFile diretorio dados

        putStrLn "Informe o proximo aluno (matricula): "
        m <- getLine
        alocarAluno m disciplina codigo