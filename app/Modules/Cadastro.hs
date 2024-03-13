{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Cadastro where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson

cadastroProfessor :: IO()
cadastroAluno :: IO()
escolherCadastro :: String -> IO()
escolherOpcaoCadastro :: IO()
cadastroGeral :: IO()

data Disciplina = Disciplina {
    nome :: String,
    nomeProfessor :: String,
    matriculaProfessor :: String,
    senha :: String
} deriving (Generic, Show)

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String
} deriving (Generic, Show)

instance ToJSON Disciplina
instance ToJSON Aluno

cadastroGeral = do
    putStrLn "CADASTRO ====================="
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Cadastro de professor"
    putStrLn "[2] Cadastro de aluno"
    putStrLn "=============================="
    escolherOpcaoCadastro

escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroProfessor
    | (escolha == "2") = cadastroAluno
    | otherwise = putStrLn "Opção Inválida" 
    
cadastroProfessor = do
    putStrLn "CADASTRO DE PROFESSOR"
    putStrLn "Nome: "
    nome <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine
    putStrLn "Nome da disciplina: "
    nomeDaDisciplina <- getLine

    validarUnico <- doesFileExist ("./db/disciplina/" ++ nomeDaDisciplina ++ ".json")

    if not validarUnico then do
        let dados = encode (Disciplina {nome = nomeDaDisciplina, nomeProfessor = nome, matriculaProfessor = matricula, senha = senha})
        B.writeFile ("./db/disciplina/" ++ nomeDaDisciplina ++ ".json") dados
        putStrLn "Cadastro concluído!"
        putStrLn " "
    else print "Nome de discipina ja esta em uso"

cadastroAluno = do
    putStrLn "CADASTRO DE ALUNO"
    putStrLn "Nome: "
    nome <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine

    validarUnico <- doesFileExist ("./db/aluno/" ++ matricula ++ ".json")

    if not validarUnico then do
        let dados = encode (Aluno {nome = nome, matricula = matricula, senha = senha})
        B.writeFile ("./db/aluno/" ++ matricula ++ ".json") dados
        putStrLn "Cadastro concluído!"
        putStrLn " "
    else print "Erro: Matricula ja esta em uso"
    