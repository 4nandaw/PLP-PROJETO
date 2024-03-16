{-# LANGUAGE DeriveGeneric #-}

module Modules.GerenciadorOpcoesDisciplina where


import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)


data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

data AlunoTurma = AlunoTurma {
    notas :: [Float],
    faltas :: Int
} deriving (Generic, Show)

instance FromJSON AlunoTurma

escolherOpcaoMenuDisciplina :: String -> String -> IO()
escolherOpcaoMenuDisciplina escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = adicionarNotas disciplina
        | otherwise = putStrLn "Opção Inválida!!"


escolherOpcaoDisciplina :: String -> IO()
escolherOpcaoDisciplina disciplina = do
    escolha <- getLine
    escolherOpcaoMenuDisciplina escolha disciplina
    if (escolha /= "0") then menuDeDisciplina disciplina
    else putStrLn " "

menuDeDisciplina :: String -> IO()
menuDeDisciplina disciplina = do
    putStrLn "MENU DE DISCIPLINA ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Adicionar notas"
    escolherOpcaoDisciplina disciplina

--validarNota :: Float -> IO()
--validarNota nota = return nota>=0 && nota<=10.0

adicionarNotas :: String -> IO()
adicionarNotas disciplina = do
    putStrLn "===== ADICIONANDO NOTAS ====="
    putStrLn " "
    putStrLn "Informe o código da turma: "
    codTurma <- getLine
    turmaValida <- doesDirectoryExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma)
    if turmaValida then do
        putStrLn "Digite o aluno que deseja alocar as notas: "
        aluno <- getLine
        alunoValido <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ aluno ++ ".json")
        if (alunoValido) then do 
            putStrLn "Pedindo as notas"
        else putStrLn "Aluno não existe"
    else putStrLn "Turma não existe!"
    