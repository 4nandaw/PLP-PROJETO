{-# LANGUAGE DeriveGeneric #-}

module Utils.Disciplina where
import GHC.Generics
import Data.Aeson

data Disciplina = Disciplina {
    matriculaProfessor :: String,
    nome :: String,
    nomeProfessor :: String,
    senha :: String
} deriving (Generic, Show)

instance FromJSON Disciplina
instance ToJSON Disciplina