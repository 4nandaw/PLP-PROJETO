{-# LANGUAGE DeriveGeneric #-}
module Modules.Login where

import Data.Aeson 
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import System.Directory(getCurrentDirectory, doesFileExist)
import Data.Text (Text)

-- Definição do tipo Professor
data Professor = Professor
    {   nomeDisciplina :: String,
        nomeProfessor :: String,
        matricula :: String,
        senha :: String }
    deriving (Generic, Show)

instance ToJSON Professor

-- Instância FromJSON para Professor
instance FromJSON Professor 

-- Função para ler dados de um arquivo JSON
-- Função para ler dados de um arquivo JSON
lerDado :: FilePath -> IO (Maybe String)
lerDado caminho = do
    arquivoExiste <- doesFileExist caminho
    if (arquivoExiste) then putStrLn "ARQUIVO EXISTE"
    else putStrLn "Arquivo não existe"
    dados <- B.readFile caminho
    case decode dados of
        Just (Professor _ _ _ senha) -> return $ Just senha
        Nothing -> return Nothing

-- Função para verificar o nome da disciplina
verificarNomeDisciplina :: String -> IO Bool
verificarNomeDisciplina nomeDisciplina = do 
    x <- lerDado("./app/Modules/" ++ nomeDisciplina ++ ".json")
    case x of
        Just resultado -> return True
        Nothing -> return False

verificarSenha :: String -> String-> IO Bool
verificarSenha nomeDisciplina senhaPassada = do
    senha <- lerDado("./app/Modules/" ++ nomeDisciplina ++ ".json")
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
    loginValido <- verificarNomeDisciplina nomeDisciplina
    if (loginValido) then do
        putStrLn "Digite a senha: "
        senha <- getLine
        senhaValida <- verificarSenha nomeDisciplina senha
        if (senhaValida) then do
            putStrLn "CHAMANDO MODULO QUE ENTRA NA DISCIPLINA DO PROFESSOR"
            putStrLn " "
        else do
            putStrLn "SENHA INVÁLIDA"
            putStrLn " "

    else do 
        putStrLn "Login inválido! Não existe disciplina com esse nome"
        putStrLn " "


        

-- Função para o login do aluno
loginAluno :: IO ()
loginAluno = do
    putStrLn "Digite a matrícula do aluno: "
    matricula <- getLine
    putStrLn "Digite a senha: "
    senha <- getLine
    putStrLn " "