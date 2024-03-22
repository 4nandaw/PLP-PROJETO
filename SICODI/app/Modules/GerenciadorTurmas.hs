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
        | (escolha == "1") = listarTurmas disciplina
        | (escolha == "2") = criarTurma disciplina
        | (escolha == "3") = solicitarEAlocarAluno disciplina
        | (escolha == "4") = excluirAluno disciplina
        | (escolha == "5") = excluirTurma disciplina
        | otherwise = putStrLn "Opção Inválida!!"

listarTurmas :: String -> IO()
listarTurmas disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas"
    listaDeTurmas <- getDirectoryContents diretorio

    putStrLn ("Turmas de " ++ disciplina)
    mapM_ (\x -> (ajustarExibirTurmas x disciplina)) listaDeTurmas
    putStrLn "==============================================="
    putStrLn "Informe um codigo de turma, ou ENTER para sair:"
    codigo <- getLine

    if codigo /= "" then do
        putStrLn "Escolha uma opção: "
        putStrLn "[1] Ver alunos da turma"
        putStrLn "[2] Ver relatório da turma"
        putStrLn "==============================================="
        opcao <- getLine
        if opcao == "1" then verAlunos (diretorio ++ "/" ++ codigo ++ "/alunos/")
        else if opcao == "2" then exibirRelatorio (diretorio ++ codigo ++ "/alunos/")
        else putStrLn "Opção inválida!"
    else putStrLn ""

ajustarExibirTurmas :: String -> String -> IO()
ajustarExibirTurmas turma disciplina = do
    if turma /= "." && turma /= ".." then do
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/alunos/"

        listaDeAlunos <- getDirectoryContents diretorio
        let numAlunos = (length listaDeAlunos) - 2

        putStrLn (turma ++ " ------ " ++ (show numAlunos) ++ " aluno(s)")    

    else putStr ""

verAlunos :: String -> IO()
verAlunos diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

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


exibirRelatorio :: String -> IO()
exibirRelatorio diretorio = do
    putStrLn ""
    putStrLn "RELATÓRIO DA TURMA ============================"
    putStrLn ""
    putStrLn $ "Média de notas: x.x" -- mediaNotas diretorio
    putStrLn ""
    mediaFaltas diretorio
    putStrLn ""
    putStrLn "==============================================="

mediaFaltas :: String -> IO()
mediaFaltas diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

    let faltasAlunos = mapM (\x -> exibirFaltas x diretorio) listaDeAlunos
    faltas <- faltasAlunos

    let faltasValidas = filter (> -1) faltas
    let tamanho = length faltasValidas
    let totalFaltas = sum faltasValidas
    let media = fromIntegral totalFaltas / fromIntegral tamanho

    putStrLn $ "Média de faltas: " ++ show media

exibirFaltas :: String -> String -> IO Int
exibirFaltas matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioAluno = diretorio ++ "/" ++ matricula
        
        alunoFaltas <- B.readFile diretorioAluno

        case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ faltas) -> return faltas
            _ -> return (-1)
    else return (-1)


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