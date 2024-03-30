{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
module Modules.Login where

import Utils.Disciplina
import Utils.Aluno
import Data.Aeson 
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import System.Directory(getCurrentDirectory, doesFileExist)
import Data.Text (Text)

arquivoDisciplinaExiste :: String -> IO Bool
arquivoDisciplinaExiste nomeDisciplina = doesFileExist ("./db/disciplinas/" ++ nomeDisciplina ++ "/" ++ nomeDisciplina ++ ".json")

arquivoAlunoExiste :: String -> IO Bool
arquivoAlunoExiste matricula = doesFileExist ("./db/alunos/" ++ matricula ++ ".json")

puxarSenhaDisciplina :: String -> IO (Maybe String)
puxarSenhaDisciplina caminho = do
    dados <- B.readFile caminho
    case decode dados of
        Just (Disciplina _ _ _ senha) -> return $ Just senha
        Nothing -> return Nothing

puxarSenhaAluno :: String -> IO (Maybe String)
puxarSenhaAluno caminho = do
    dados <- B.readFile caminho
    case decode dados of
        Just (Aluno _ _ senha _) -> return $ Just senha
        Nothing -> return Nothing


verificarSenhaDisciplina :: String -> String-> IO Bool
verificarSenhaDisciplina nomeDisciplina senhaPassada = do
    senha <- puxarSenhaDisciplina("./db/disciplinas/" ++ nomeDisciplina ++ "/" ++ nomeDisciplina ++ ".json")
    case senha of
        Just senha -> return (senha==senhaPassada)
        Nothing -> return False

verificarSenhaAluno :: String -> String-> IO Bool
verificarSenhaAluno matricula senhaPassada = do
    senha <- puxarSenhaAluno("./db/alunos/" ++ matricula ++ ".json")
    case senha of
        Just senha -> return (senha==senhaPassada)
        Nothing -> return False

-- Função para o login do professor
loginProfessor :: String -> String -> IO Bool
loginProfessor disciplina senha= do
    loginValido <- arquivoDisciplinaExiste disciplina
    if (loginValido) then do
        senhaValida <- verificarSenhaDisciplina disciplina senha
        if (senhaValida) then return True
        else return False
    else return False


-- Função para o login do aluno
loginAluno :: String -> String-> IO Bool
loginAluno matricula senha = do
    loginValido <- arquivoAlunoExiste matricula
    if (loginValido) then do
        senhaValida <- verificarSenhaAluno matricula senha
        if (senhaValida) then return True
        else return False
    else return False