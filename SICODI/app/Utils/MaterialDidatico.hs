{-# LANGUAGE DeriveGeneric #-}

module Utils.MaterialDidatico where
import GHC.Generics
import Data.Aeson

data MaterialDidatico = MaterialDidatico {
    materialDidatico :: [(String, String)]
} deriving (Generic, Show)

instance FromJSON MaterialDidatico
instance ToJSON MaterialDidatico