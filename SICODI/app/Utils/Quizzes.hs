{-# LANGUAGE DeriveGeneric #-}

module Utils.Quizzes where
import GHC.Generics
import Data.Aeson

data Quizzes = Quizzes{
    quizzes:: [String]
} deriving (Generic, Show)

instance FromJSON Quizzes
instance ToJSON Quizzes