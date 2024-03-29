{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorOpcoesAluno where
import Utils.Avaliacao 
import Modules.GerenciadorOpcoesDisciplina as OpcoesDisciplina
import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String,
    turmas :: [[String]]
} deriving (Generic, Show)

instance ToJSON Aluno
instance FromJSON Aluno

listarDisciplinasTurmas :: String -> IO String
listarDisciplinasTurmas matricula = do
    let diretorio = "./db/alunos/" ++ matricula ++ ".json"
    aluno <- B.readFile diretorio
    case decode aluno of
        Just (Aluno _ _ _ turmas) -> do
            let listaDiscipinasTurmas = map (\x -> ajustarExibirDisciplinaTurma x) turmas
            return $ unlines $ listaDiscipinasTurmas
        Nothing -> return "Erro"    

ajustarExibirDisciplinaTurma :: [String] -> String
ajustarExibirDisciplinaTurma [disciplina, turma] = "Disciplina: " ++ disciplina ++ ". Turma: " ++ turma

turmaValida :: String -> String -> String -> IO Bool
turmaValida matricula disciplina turma = do
     let diretorio = "./db/alunos/" ++ matricula ++ ".json"
     aluno <- B.readFile diretorio
     case decode aluno of 
        Just (Aluno _ _ _ turmas) -> do
            if (elem [disciplina, turma] turmas) then return True
            else return False

acessarChatAluno :: String -> String -> String -> IO String
acessarChatAluno matricula disciplina turma = do
    chat <- OpcoesDisciplina.acessarChat disciplina turma matricula
    return chat


visualizarNotas :: String -> String -> String -> IO String
visualizarNotas matricula disciplina codTurma = do
    situacao <- OpcoesDisciplina.situacaoAluno disciplina codTurma matricula
    return situacao
                    
salvarAvaliacao :: String -> Int -> String -> String -> IO String
salvarAvaliacao diretorio nota comentario matricula = do
    let diretorioAvaliacao = diretorio ++ matricula ++ ".json"
    let dados = encode (Avaliacao {nota = nota, comentario = comentario})
    B.writeFile diretorioAvaliacao dados
    return "Avaliação registrada!"