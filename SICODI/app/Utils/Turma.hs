{-# LANGUAGE DeriveGeneric #-}

module Utils.Turma where
import GHC.Generics
import Data.Aeson

data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

instance FromJSON Turma
instance ToJSON Turma