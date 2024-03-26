{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorTurmas where

import Utils.AlunoTurma
import Utils.Avaliacao
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

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String,
    turmas :: [[String]]
} deriving (Generic, Show)

instance ToJSON Turma
instance FromJSON Turma

instance ToJSON Aluno
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

verAvaliacoes :: String -> IO String
verAvaliacoes diretorio = do
    listaDeAvaliacoes <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    response <- mapM (\x -> (exibirAvaliacao x diretorio)) listaDeAvaliacoes

    return (unlines $ response)

exibirAvaliacao :: String -> String -> IO String
exibirAvaliacao arquivo diretorio = do
    if arquivo /= "." && arquivo /= ".." then do
        let caminho = diretorio ++ arquivo

        avaliacao <- B.readFile caminho

        nota <- case decode avaliacao of 
            Just (Avaliacao nota _) -> return $ show nota
            Nothing -> return ""

        comentario <- case decode avaliacao of 
            Just (Avaliacao _ comentario) -> return comentario
            Nothing -> return ""

        notaFormatada <- formataNota nota

        return (notaFormatada ++ "\n" ++ "Comentário: " ++ comentario ++ "\n")
    else return ""

formataNota :: String -> IO String
formataNota nota
    | (nota == "1") = return "⭑☆☆☆☆"
    | (nota == "2") = return "⭑⭑☆☆☆"
    | (nota == "3") = return "⭑⭑⭑☆☆"
    | (nota == "4") = return "⭑⭑⭑⭑☆"
    | (nota == "5") = return "⭑⭑⭑⭑⭑"
    | otherwise = return ""

mediaAvaliacoes :: String -> IO String
mediaAvaliacoes diretorio = do
    listaDeAvaliacoes <- getDirectoryContents diretorio

    let notasAvaliacoes = mapM (\x -> exibirNota x diretorio) listaDeAvaliacoes
    notas <- notasAvaliacoes

    let notasValidas = filter (/= -1) notas
    let quantidade = length notasValidas
    let somaNotas = sum notasValidas
    let media = fromIntegral somaNotas / fromIntegral quantidade

    return $ "Nota média: " ++ show media

exibirNota :: String -> String -> IO Int
exibirNota arquivo diretorio = do
    if arquivo /= "." && arquivo /= ".." then do
        let caminho = diretorio ++ arquivo

        avaliacao <- B.readFile caminho

        case decode avaliacao of 
            Just (Avaliacao nota _) -> return nota
            _ -> return (-1)
    else return (-1)

criarTurma :: String -> String -> String -> IO String
criarTurma disciplina nome codigo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json"
    let avaliacoes = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/avaliacoes/"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        createDirectoryIfMissing True $ takeDirectory diretorio
        createDirectoryIfMissing True $ takeDirectory avaliacoes

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
            Nothing -> return ()
        let dados = encode (AlunoTurma {faltas = 0, nota1 = 0.0, nota2 = 0.0, nota3 = 0.0, media = 0.0})
        B.writeFile diretorio dados

        return $ "Adicionado " ++ matriculaAluno
