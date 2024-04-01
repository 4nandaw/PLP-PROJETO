{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Cadastro where

import Utils.Disciplina
import Utils.Aluno
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import Data.Char (isSpace)
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)


cadastroDisciplina :: String -> String -> String -> String -> IO Bool
cadastroDisciplina nomeProfessor matriculaProfessor senha nomeDisciplina = do
    createDirectoryIfMissing True $ takeDirectory "./db/disciplinas/"

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
    createDirectoryIfMissing True $ takeDirectory "./db/alunos/"

    validarUnico <- doesFileExist ("./db/alunos/" ++ matricula ++ ".json")

    if not validarUnico then do
        let dados = encode (Aluno {nome = nome, matricula = matricula, senha = senha, turmas = []})
        B.writeFile ("./db/alunos/" ++ matricula ++ ".json") dados
        return True
    else return False

validandoString :: String -> Bool  
validandoString string = not (all isSpace string || null string)

validandoDadosProfessor :: String -> String -> String -> String -> Bool
validandoDadosProfessor nomeProfessor matricula senha nomeDisciplina = do
    let valido = validandoString nomeProfessor && validandoString matricula && validandoString senha && validandoString nomeDisciplina
    if valido then True
    else False

validandoDadosAluno :: String -> String -> String -> Bool
validandoDadosAluno nome matricula senha = do
    let valido = validandoString nome && validandoString matricula && validandoString senha
    if valido then True
    else False
