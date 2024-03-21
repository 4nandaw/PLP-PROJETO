{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
module Modules.Login where

import Data.Aeson 
import Modules.MenuProfessor
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import System.Directory(getCurrentDirectory, doesFileExist)
import Data.Text (Text)

-- Definição do tipo Disciplina
data Disciplina = Disciplina
    {   nome :: String,
        nomeProfessor :: String,
        matriculaProfessor :: String,
        senha :: String }
    deriving (Generic, Show)

--Definição do tipo Aluno
data Aluno = Aluno
    {   nome :: String,
        matricula :: String,
        senha :: String
    } deriving(Generic, Show)

--Instâncias de Disciplina/Aluno para Json
instance ToJSON Disciplina
instance ToJSON Aluno

-- Instâncias de Json para Disciplina/Aluno
instance FromJSON Disciplina
instance FromJSON Aluno

-- Função para verificar se um arquivo existe
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
        Just (Aluno _ _ senha) -> return $ Just senha
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

-- Função para o login geral
loginGeral :: IO ()
loginGeral = do
    putStrLn "Login ======================"
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Login de professor"
    putStrLn "[2] Login de aluno"
    putStrLn "============================="
    escolherOpcaoLogin

-- Função para escolher a opção de login
escolherOpcaoLogin :: IO ()
escolherOpcaoLogin = do
    escolha <- getLine 
    escolherLogin escolha

-- Função para realizar o login
escolherLogin :: String -> IO ()
escolherLogin escolha 
    | escolha == "0" = putStr ""
    | escolha == "1" = loginProfessor
    | escolha == "2" = loginAluno
    | otherwise = putStrLn "Opção Inválida" 

-- Função para o login do professor
loginProfessor :: IO ()
loginProfessor = do
    putStrLn "Digite o nome da disciplina: "
    nomeDisciplina <- getLine
    loginValido <- arquivoDisciplinaExiste nomeDisciplina
    if (loginValido) then do
        putStrLn "Digite a senha: "
        senha <- getLine
        senhaValida <- verificarSenhaDisciplina nomeDisciplina senha
        if (senhaValida) then do
            Modules.MenuProfessor.exibirMenuProfessor nomeDisciplina
            putStrLn " "
        else do
            putStrLn "SENHA INVÁLIDA!"
            putStrLn " "

    else do 
        putStrLn "Login inválido! Não existe disciplina com esse nome"
        putStrLn " "


        

-- Função para o login do aluno
loginAluno :: IO ()
loginAluno = do
    putStrLn "Digite a matrícula do aluno: "
    matricula <- getLine
    loginValido <- arquivoAlunoExiste matricula
    if (loginValido) then do
        putStrLn "Digite a senha: "
        senha <- getLine
        senhaValida <- verificarSenhaAluno matricula senha
        if (senhaValida) then do 
            putStrLn "CHAMANDO MODULO QUE ENTRA NA CONTA DO ALUNO"
            putStrLn " "
        else do
            putStrLn "SENHA INVÁLIDA!"
            putStrLn " "
    else do 
        putStrLn "Login Inválido! Não existe aluno com essa matrícula"
        putStrLn " "