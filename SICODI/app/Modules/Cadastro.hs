{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Cadastro where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)


data Disciplina = Disciplina {
    nome :: String,
    nomeProfessor :: String,
    matriculaProfessor :: String,
    senha :: String
} deriving (Generic, Show)

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String,
    turmas :: [[String]]
} deriving (Generic, Show)

instance ToJSON Disciplina
instance ToJSON Aluno
    
cadastroDisciplina :: String -> String -> String -> String -> IO Bool
cadastroDisciplina nomeProfessor matricula senha nomeDisciplina = do
    let diretorio = "./db/disciplinas/" ++ nomeDisciplina ++ "/" ++ nomeDisciplina ++ ".json"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        let dados = encode (Disciplina {nome = nomeDisciplina, nomeProfessor = nomeProfessor, matriculaProfessor = matricula, senha = senha})

        createDirectoryIfMissing True $ takeDirectory diretorio

        B.writeFile diretorio dados
        return True
    else return False

cadastroAluno :: String -> String -> String-> IO Bool
cadastroAluno nome matricula senha = do
    
    validarUnico <- doesFileExist ("./db/alunos/" ++ matricula ++ ".json")

    if not validarUnico then do
        let dados = encode (Aluno {nome = nome, matricula = matricula, senha = senha, turmas = []})
        B.writeFile ("./db/alunos/" ++ matricula ++ ".json") dados
        return True
    else return False
  