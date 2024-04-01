{-# LANGUAGE DeriveGeneric #-}

module Utils.Quiz where
import GHC.Generics
import Data.Aeson

data Quiz = Quiz {
         perguntas :: [String], 
         respostas :: [Bool]
} deriving (Generic, Show)

instance ToJSON Quiz
instance FromJSON Quiz