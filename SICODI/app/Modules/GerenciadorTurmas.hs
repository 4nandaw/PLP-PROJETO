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
    media :: Float,
    faltas :: Int
} deriving (Generic, Show)

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String,
    turmas :: [[String]]
} deriving (Generic, Show)

instance ToJSON Turma
instance ToJSON AlunoTurma
instance ToJSON Aluno

instance FromJSON AlunoTurma
instance FromJSON Aluno

listarTurmas :: String -> IO String
listarTurmas disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    createDirectoryIfMissing True $ takeDirectory diretorio

    listaDeTurmas <- getDirectoryContents diretorio

    response <- mapM (\x -> (ajustarExibirTurmas x disciplina)) listaDeTurmas

    return (unlines $ response)

ajustarExibirTurmas :: String -> String -> IO String
ajustarExibirTurmas turma disciplina = do
    if turma /= "." && turma /= ".." then do
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/alunos/"

        createDirectoryIfMissing True $ takeDirectory diretorio

        listaDeAlunos <- getDirectoryContents diretorio
        let numAlunos = (length listaDeAlunos) - 2

        return (turma ++ " ------ " ++ (show numAlunos) ++ " aluno(s)")
    else return ""

verAlunos :: String -> IO String
verAlunos diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    response <- mapM (\x -> (exibirAluno x diretorio)) listaDeAlunos

    return (unlines $ response)

exibirAluno :: String -> String -> IO String
exibirAluno matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioInfo = "./db/alunos/" ++ matricula
        let diretorioA = diretorio ++ matricula

        aluno <- B.readFile diretorioInfo
        alunoFaltas <- B.readFile diretorioA

        nome <- case decode aluno of 
            Just (Aluno nome _ _ _) -> return $ nome
            Nothing -> return ""

        matriculaDecode <- case decode aluno of 
            Just (Aluno _ matricula _ _ ) -> return $ matricula
            Nothing -> return ""

        faltas <- case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ _ faltas) -> return $ faltas
            Nothing -> return 0

        return (matriculaDecode ++ " - " ++ nome ++ " ----- " ++ (show faltas) ++ " falta(s)")
      else return ""

exibirRelatorio :: String -> IO String
exibirRelatorio diretorio = do
    mediaF <- mediaFaltas diretorio
    mediaN <- mediaNotas diretorio
    return $ "\nRELATÓRIO DA TURMA ============================\n\n" ++
        mediaN ++ "\n\n" ++ mediaF ++
        "\n\n==============================================="

mediaFaltas :: String -> IO String
mediaFaltas diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

    let faltasAlunos = mapM (\x -> exibirFaltas x diretorio) listaDeAlunos
    faltas <- faltasAlunos

    let faltasValidas = filter (> -1) faltas
    let tamanho = length faltasValidas
    let totalFaltas = sum faltasValidas
    let media = fromIntegral totalFaltas / fromIntegral tamanho

    return $ "Média de faltas: " ++ show media

exibirFaltas :: String -> String -> IO Int
exibirFaltas matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioAluno = diretorio ++ "/" ++ matricula
        
        alunoFaltas <- B.readFile diretorioAluno

        case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ _ faltas) -> return faltas
            _ -> return (-1)
    else return (-1)

mediaNotas :: String -> IO String
mediaNotas diretorio = do
    listaDeAlunos <- getDirectoryContents diretorio

    let notasAlunos = mapM (\x -> exibirNotas x diretorio) listaDeAlunos
    notas <- notasAlunos

    let notasValidas = filter (> -1) notas
    let tamanho = length notasValidas
    let totalNotas = sum notasValidas
    let media = totalNotas / fromIntegral tamanho

    return $ "Média de notas: " ++ show media

exibirNotas :: String -> String -> IO Float
exibirNotas matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioAluno = diretorio ++ "/" ++ matricula
        
        alunoNotas <- B.readFile diretorioAluno

        case decode alunoNotas of 
            Just (AlunoTurma _ _ _ notas _) -> return notas
            _ -> return (-1)
    else return (-1)

criarTurma :: String -> String -> String -> IO String
criarTurma disciplina nome codigo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        createDirectoryIfMissing True $ takeDirectory diretorio

        let dados = encode (Turma {nome = nome, codigo = codigo, alunos = []})
        B.writeFile diretorio dados
        return "Cadastro concluído!"

    else return "Erro: Codigo de turma ja esta em uso"

excluirAluno :: String ->  String -> IO String
excluirAluno disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "Turma invalida"
    else return ""

removerAluno :: String -> String -> String -> IO String
removerAluno disciplina matricula codigo = do
        let diretorioAluno = ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matricula ++ ".json")

        validarExistenciaAluno <- doesFileExist diretorioAluno

        if not validarExistenciaAluno then return "Aluno nao esta na turma ou nao existe"
        else do
            removeFile diretorioAluno
            return "Aluno removido!"



excluirTurma :: String -> String -> IO String
excluirTurma disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "Turma invalida"
    else do
        removeDirectoryRecursive ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo)
        return "Turma removida!"

solicitarEAlocarAluno :: String -> String -> IO String
solicitarEAlocarAluno disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "Codigo invalido!"
    else return ""

alocarAluno :: String -> String -> String -> IO String
alocarAluno matriculaAluno disciplina codigo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matriculaAluno ++ ".json"
    let diretorioAluno = ("./db/alunos/" ++ matriculaAluno ++ ".json")
    validarMatricula <- doesFileExist ("./db/alunos/" ++ matriculaAluno ++ ".json")

    if not validarMatricula then return "Matricula invalida"
    else do
        createDirectoryIfMissing True $ takeDirectory diretorio
        dadosAluno <- B.readFile diretorioAluno
        case decode dadosAluno of 
            Just (Aluno matricula nome senha turmas) -> do
                let dadosAlunoAtualizado = encode(Aluno {matricula = matricula, nome = nome, senha = senha, turmas = turmas ++ [[disciplina, codigo]]})
                B.writeFile diretorioAluno dadosAlunoAtualizado
                
        let dados = encode (AlunoTurma {faltas = 0, nota1 = 0.0, nota2 = 0.0, nota3 = 0.0, media = 0.0})
        B.writeFile diretorio dados

        return $ "Adicionado " ++ matriculaAluno
