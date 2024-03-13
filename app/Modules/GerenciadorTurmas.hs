{-# LANGUAGE DeriveGeneric #-}

module Modules.GerenciadorTurmas where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson

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
    putStrLn "[3] Alocar turma"
    putStrLn "===================="
    escolherOpcaoTurma disciplina

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "1") = putStrLn "Lista"
        | (escolha == "2") = criarTurma
        | (escolha == "3") = putStrLn "Alocar"
        | otherwise = putStrLn "Opção Inválida!!"

criarTurma :: IO()
criarTurma = do
    putStrLn "CADASTRO DE TURMA"
    putStrLn "Nome da turma: "
    nome <- getLine
    putStrLn "Codigo da turma: "
    codigo <- getLine

    validarUnico <- doesFileExist ("./db/turma/" ++ codigo ++ ".json")

    if not validarUnico then do
        putStrLn "Informe a lista de matriculas de alunos (separado por espacos): "
        matriculas <- getLine
        let listaMatriculas = words matriculas

        let dados = encode (Turma {nome = nome, codigo = codigo, alunos = listaMatriculas})
        B.writeFile ("./db/turma/" ++ codigo ++ ".json") dados
        putStrLn "Cadastro concluído!"
        putStrLn " "
    else print "Erro: Codigo ja esta em uso"

