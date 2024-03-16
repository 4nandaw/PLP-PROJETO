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
        | (escolha == "1") = solicitarEAlocarNotas disciplina
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



listarAlunosTurma :: String -> IO()
listarAlunosTurma diretorio = do 
    putStrLn ("LISTA DE ALUNOS NA TURMA DO SEGUINTE CAMINHO" ++ diretorio)
    putStrLn ""
    putStrLn "=================="

solicitarEAlocarNotas :: String -> IO()
solicitarEAlocarNotas disciplina = do
    putStrLn "===== ADICIONANDO NOTAS ===== "
    putStrLn " "
    putStrLn "Informe o código da turma: "
    codTurma <- getLine
    turmaValida <- doesDirectoryExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma)
    if turmaValida then do 
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma
        listarAlunosTurma diretorio 
        adicionarNotasTurma disciplina codTurma
    else putStrLn "Turma não existe!"

validarNota :: Float -> IO Bool
validarNota nota
    | (nota<0) = return False
    | (nota>10.0) = return False
    | otherwise = return True

salvarNota :: String -> String -> String -> String -> IO()
salvarNota disciplina codTurma matriculaAluno escolha = do
    putStrLn "Digite o valor da nota: "
    nota <- readLn :: IO Float
    notaValida <- validarNota nota
    if (notaValida) then do
        putStrLn "SALVANDO A NOTA NO ARQUIVO"
    else 
        putStrLn "Nota inválida"



menuNotas :: String -> String -> String -> IO()
menuNotas disciplina codTurma matriculaAluno = do
    putStrLn("===== ADICIONANDO NOTAS DO ALUNO " ++ matriculaAluno ++ " =====")
    putStrLn " "
    putStrLn "Digite qual nota você quer adicionar: "
    putStrLn "[0] para voltar"
    putStrLn "[1] para adicionar a 1º nota"
    putStrLn "[2] para adicionar a 2º nota"
    putStrLn "[3] para adicionar a 3º nota"
    putStrLn "[4] para adicionar a 4º nota" 
    escolha <- getLine
    if (escolha == "0") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4") then do
            putStrLn "Opção Inválida"
            menuNotas disciplina codTurma matriculaAluno
        else do
            if (escolha == "4") then do 
                putStrLn "EXIBINDO SITUAÇÃO DO ALUNO"
                menuNotas disciplina codTurma matriculaAluno

            else do 
                salvarNota disciplina codTurma matriculaAluno escolha
                menuNotas disciplina codTurma matriculaAluno

adicionarNotasTurma :: String -> String -> IO()
adicionarNotasTurma disciplina codTurma = do
    putStrLn "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair "
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn "Registro de notas finalizado!"
    else do
        alunoValido <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
            adicionarNotasTurma disciplina codTurma
        else do 
            putStrLn "Aluno não existe" 
            adicionarNotasTurma disciplina codTurma
    