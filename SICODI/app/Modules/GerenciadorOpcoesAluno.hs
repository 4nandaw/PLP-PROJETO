{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}


module Modules.GerenciadorOpcoesAluno where
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
--instance ToJSON AlunoTurma

instance FromJSON Aluno
--instance FromJSON AlunoTurma


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



visualizarNotas :: String -> String -> String -> IO String
visualizarNotas matricula disciplina turma = do
    --let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/alunos/" ++ matricula ++ ".json"
    situacao <- OpcoesDisciplina.situacaoAluno disciplina turma matricula
    return situacao

    {-case decode alunoTurma of 
        Just (AlunoTurma nota1 nota2 nota3 _) -> then do
            return situacao
        Nothing -> return "Erro na leitura das notas!"
    where situacao = "Nota 1: " ++ nota1 ++ "\n" ++
                    "Nota 2 " ++ nota2 ++ "\n" ++
                    "Nota3: " ++ nota3 ++ "\n" ++
                    "Média: " ++ 
                    -}
                    
