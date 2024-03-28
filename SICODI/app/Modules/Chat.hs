{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Chat where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson

import Utils.Disciplina
import Utils.Aluno

data Chat = Chat {
    chat :: [[String]]
} deriving (Generic, Show)

instance ToJSON Chat
instance FromJSON Chat

append :: [String] -> [[String]] -> [[String]]
append a xs = xs ++ [a] 

enviarMensagem :: String -> String -> String -> String -> String -> IO String
enviarMensagem disciplina codTurma remetente matricula mensagem = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/chats/" ++ codTurma ++ "-" ++ matricula ++ ".json"
    
    dados <- B.readFile diretorio

    chatAntigo <- case decode dados of
        Just (Chat chat) -> return chat
        Nothing -> return [["", ""]]

    let chatNovo = append [remetente, mensagem] chatAntigo

    let chat = encode (Chat {chat =  chatNovo})

    B.writeFile diretorio chat

    return ""
    
lerNomeProfessor :: String -> IO String
lerNomeProfessor disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/" ++ disciplina ++ ".json"
    
    dados <- B.readFile diretorio
    nomeProfessor  <- case decode dados of
        Just (Disciplina _ _ nomeProfessor _) -> return nomeProfessor
        Nothing -> return ""

    return nomeProfessor

lerNomeAluno :: String -> IO String
lerNomeAluno matricula = do
    let diretorio = "./db/alunos/" ++ matricula ++ ".json"
    
    dados <- B.readFile diretorio
    nomeAluno  <- case decode dados of
        Just (Aluno _ nome _ _) -> return nome
        Nothing -> return ""

    return nomeAluno