{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Cadastro where

import Utils.Disciplina
import Utils.Aluno
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)


cadastroDisciplina :: String -> String -> String -> String -> IO Bool
cadastroDisciplina nomeProfessor matriculaProfessor senha nomeDisciplina = do
    let diretorio = "./db/disciplinas/" ++ nomeDisciplina ++ "/" ++ nomeDisciplina ++ ".json"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        let dados = encode (Disciplina {matriculaProfessor = matriculaProfessor, nome = nomeDisciplina, nomeProfessor = nomeProfessor, senha = senha})

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
  