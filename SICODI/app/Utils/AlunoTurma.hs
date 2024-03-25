{-# LANGUAGE DeriveGeneric #-}

module Utils.AlunoTurma where
import GHC.Generics
import Data.Aeson


data AlunoTurma = AlunoTurma {
    nota1 :: Float,
    nota2 :: Float,
    nota3 :: Float,
    media :: Float,
    faltas :: Int
} deriving (Generic, Show)

instance FromJSON AlunoTurma
instance ToJSON AlunoTurma


