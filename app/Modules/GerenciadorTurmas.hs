{-# LANGUAGE DeriveGeneric #-}

module Modules.GerenciadorTurmas where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)

data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

instance ToJSON Turma

escolherOpcaoTurma :: String -> IO()
escolherOpcaoTurma disciplina = do
    escolha <- getLine
    escolherOpcaoMenuTurmas escolha disciplina
    if (escolha /= "0") then opcoesDeTurmas disciplina
    else putStrLn " "

opcoesDeTurmas :: String -> IO()
opcoesDeTurmas disciplina = do
    putStrLn "MENU DE TURMAS ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Minhas turmas"
    putStrLn "[2] Criar turma"
    putStrLn "===================="
    escolherOpcaoTurma disciplina

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "1") = putStrLn "Lista"
        | (escolha == "2") = criarTurma disciplina
        | (escolha == "3") = putStrLn "Alocar"
        | otherwise = putStrLn "Opção Inválida!!"

criarTurma :: String -> IO()
criarTurma disciplina = do
    putStrLn "CADASTRO DE TURMA"
    putStrLn "Nome da turma: "
    nome <- getLine
    putStrLn "Codigo da turma: "
    codigo <- getLine

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        createDirectoryIfMissing True $ takeDirectory diretorio

        let dados = encode (Turma {nome = nome, codigo = codigo, alunos = []})
        B.writeFile diretorio dados
        putStrLn "Cadastro concluído!"
        putStrLn " "

    else print "Erro: Codigo de turma ja esta em uso"
