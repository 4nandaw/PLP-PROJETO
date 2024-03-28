{-# LANGUAGE DeriveGeneric #-}

module Utils.Chat where
import GHC.Generics
import Data.Aeson

data Chat = Chat {
    chat :: [[String]]
} deriving (Generic, Show)

instance ToJSON Chat
instance FromJSON Chat