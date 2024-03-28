{-# LANGUAGE DeriveGeneric #-}

module Utils.Mural where
import GHC.Generics
import Data.Aeson

data Mural = Mural {
    aviso :: [String]
} deriving (Generic, Show)

instance FromJSON Mural
instance ToJSON Mural