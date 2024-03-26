{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.Chat where

import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson

data Chat = Chat {
    chat :: [[String]]
} deriving (Generic, Show)

instance ToJSON Chat
instance FromJSON Chat

append :: [String] -> [[String]] -> [[String]]
append a xs = xs ++ [a] 

enviarMensagem :: String -> String -> String -> String -> String -> IO()
enviarMensagem disciplina codTurma remetente matricula mensagem = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/chats/" ++ codTurma ++ "-" ++ matricula ++ ".json"
    
    dados <- B.readFile diretorio

    chatAntigo <- case decode dados of
        Just (Chat chat) -> return chat
        Nothing -> return [["", ""]]

    let chatNovo = append [remetente, mensagem] chatAntigo

    let chat = encode (Chat {chat =  chatNovo})

    B.writeFile diretorio chat
    
