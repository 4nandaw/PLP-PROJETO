{-# LANGUAGE DeriveGeneric #-}

module Modules.GerenciadorOpcoesDisciplina where


import Utils.AlunoTurma
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)
import Data.Maybe (isJust)
import Text.Read (readMaybe)
import Text.Printf
import Numeric 


data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

solicitarEAlocarNotas :: String -> String -> IO Bool
solicitarEAlocarNotas disciplina codTurma = do
    turmaValida <- doesDirectoryExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma)
    if turmaValida then do 
        return True
    else return False

validarNota :: String -> IO Bool
validarNota notaStr =
    case readMaybe notaStr :: Maybe Float of
        Just nota -> return (nota>=0 && nota<=10)
        Nothing -> return False

atualizarMedia :: String -> String -> String -> IO String
atualizarMedia disciplina codTurma matriculaAluno = do
    let diretorio = ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    dados <- B.readFile diretorio
    case decode dados of
        Just (AlunoTurma nota1 nota2 nota3 _ faltas)-> do
            let media = printf "%.1f" ((nota1 + nota2 + nota3)/3)
                mediaF = read media :: Float
                alunoMediaAtualizada = AlunoTurma nota1 nota2 nota3 mediaF faltas
            B.writeFile diretorio (encode alunoMediaAtualizada)
            return "Média atualizada"
        Nothing -> return "Erro na atualização da média"


salvarNota :: String -> String -> String -> String -> String -> IO String
salvarNota disciplina codTurma matriculaAluno escolha nota = do
    notaValida <- validarNota nota
    if (notaValida) then do
        dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
        let notaAtualizada = read nota
        case decode dados of
            Just (AlunoTurma nota1 nota2 nota3 media faltas)-> do
                let alunoNotaAtualizada = case escolha of
                        "1" -> AlunoTurma notaAtualizada nota2 nota3 media faltas
                        "2" -> AlunoTurma nota1 notaAtualizada nota3 media faltas
                        "3" -> AlunoTurma nota1 nota2 notaAtualizada media faltas
                        _ -> AlunoTurma nota1 nota2 nota3 media faltas
                B.writeFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json") (encode alunoNotaAtualizada)
                atualizarMedia disciplina codTurma matriculaAluno
                return "NOTA SALVA NO ARQUIVO"
            Nothing -> return "Erro!!!"
    else 
        return "Nota inválida"

situacaoAluno :: String -> String -> String -> IO String
situacaoAluno disciplina codTurma matriculaAluno = do
    dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    case decode dados of 
        Just (AlunoTurma nota1 nota2 nota3 media faltas) -> do
            let situacao = if media >= 7
                               then "Aprovado :)"
                               else if media >= 4 && media <= 6.9
                                        then "Final :|"
                                        else "Reprovado :("
            return $ "===== SITUAÇÃO DO ALUNO(A) " ++ matriculaAluno ++ " =====\n\n" ++
                     "Nota 1: " ++ show nota1 ++ "\n" ++
                     "Nota 2: " ++ show nota2 ++ "\n" ++
                     "Nota 3: " ++ show nota3 ++ "\n" ++
                     printf "Média: %.1f\n" media ++
                     situacao
        Nothing -> return "Erro: Dados não encontrados para o aluno."

verificarAlunoTurma :: String -> String -> String-> IO Bool
verificarAlunoTurma disciplina codTurma matriculaAluno = do
    alunoValido <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    if (alunoValido) then do 
        return True
    else do 
        return False