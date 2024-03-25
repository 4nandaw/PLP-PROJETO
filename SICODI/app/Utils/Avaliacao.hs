{-# LANGUAGE DeriveGeneric #-}

module Utils.Avaliacao where
import GHC.Generics
import Data.Aeson

data Avaliacao = Avaliacao {
    nota :: Int,
    comentario :: String
} deriving (Generic, Show)

instance FromJSON Avaliacao
instance ToJSON Avaliacao


