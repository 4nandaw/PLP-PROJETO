{-# LANGUAGE DeriveGeneric #-}
module Modules.Login where

import Data.Aeson 
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import System.Directory(getCurrentDirectory)
import Data.Text (Text)

-- Definição do tipo Professor
data Professor = Professor { nomeDisciplia :: String, nomeProfessor :: String, matricula :: String, senha :: String }
    deriving (Generic, Show)

-- Instância FromJSON para Professor
instance FromJSON Professor
instance ToJSON Professor

-- Função para ler dados de um arquivo JSON
lerDado :: FilePath -> IO (Maybe String)
lerDado caminho = do
    dados <- B.readFile caminho
    case decode dados of
        Just (Professor _ senha _ _) -> return $ Just senha
        Nothing -> return Nothing

-- Função para verificar o nome da disciplina
verificarNomeDisciplina :: String -> IO ()
verificarNomeDisciplina nomeDisciplina = do 
    putStrLn "TESTE"
    y <- getCurrentDirectory
    putStrLn y
    x <- lerDado("C:/Users/josej/OneDrive/Documentos/Jardel/UFCG/PLP/PLP-PROJETO/app/Modules/plp.json")
    case x of
        Just resultado -> putStrLn(show(resultado))
        Nothing -> putStrLn "Erro"

-- Função para o login geral
loginGeral :: IO ()
loginGeral = do
    putStrLn "Login ====================="
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Login de professor"
    putStrLn "[2] Login de aluno"
    putStrLn "=============================="
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
    verificarNomeDisciplina nomeDisciplina
    putStrLn "Digite a senha: "
    senha <- getLine
    putStrLn " "

-- Função para o login do aluno
loginAluno :: IO ()
loginAluno = do
    putStrLn "Digite a matrícula do aluno: "
    matricula <- getLine
    putStrLn "Digite a senha: "
    senha <- getLine
    putStrLn " "