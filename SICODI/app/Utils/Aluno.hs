{-# LANGUAGE DeriveGeneric #-}

module Utils.Aluno where
import GHC.Generics
import Data.Aeson

data Aluno = Aluno {
    nome :: String,
    matricula :: String,
    senha :: String,
    turmas :: [[String]]
} deriving (Generic, Show)

instance ToJSON Aluno
instance FromJSON Aluno