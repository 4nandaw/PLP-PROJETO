{-# LANGUAGE DeriveGeneric #-}

module Modules.GerenciadorOpcoesDisciplina where


import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)
import Data.Maybe (isJust)
import Text.Read (readMaybe)
import Text.Printf

data Turma = Turma {
    nome :: String,
    codigo :: String,
    alunos :: [String]
} deriving (Generic, Show)

data AlunoTurma = AlunoTurma {
    nota1 :: Float,
    nota2 :: Float,
    nota3 :: Float,
    faltas :: Int
} deriving (Generic, Show)

instance FromJSON AlunoTurma
instance ToJSON AlunoTurma

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

validarNota :: String -> IO Bool
validarNota notaStr =
    case readMaybe notaStr :: Maybe Float of
        Just nota -> return (nota>=0 && nota<=10)
        Nothing -> return False

salvarNota :: String -> String -> String -> String -> IO()
salvarNota disciplina codTurma matriculaAluno escolha = do
    putStrLn "Digite o valor da nota: "
    notaAtualizadaString <- getLine
    notaValida <- validarNota notaAtualizadaString
    if (notaValida) then do
        dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
        let notaAtualizada = read notaAtualizadaString
        case decode dados of
            Just (AlunoTurma nota1 nota2 nota3 faltas)-> do
                let alunoNotaAtualizada = case escolha of
                        "1" -> AlunoTurma notaAtualizada nota2 nota3 faltas
                        "2" -> AlunoTurma nota1 notaAtualizada nota3 faltas
                        "3" -> AlunoTurma nota1 nota2 notaAtualizada faltas
                        _ -> AlunoTurma nota1 nota2 nota3 faltas
                B.writeFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json") (encode alunoNotaAtualizada)
                putStrLn "SALVANDO A NOTA NO ARQUIVO"
            Nothing -> putStrLn "Erro!!!"
    else 
        putStrLn "Nota inválida"

situacaoAluno :: String -> String -> String -> IO()
situacaoAluno disciplina codTurma matriculaAluno = do
    dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    case decode dados of 
        Just (AlunoTurma nota1 nota2 nota3 faltas)-> do
            putStrLn $ "===== SITUAÇÃO DO ALUNO(A)" ++ matriculaAluno ++ "====="
            putStrLn " "
            putStrLn $ "Nota 1: " ++ show nota1
            putStrLn $ "Nota 2: " ++ show nota2
            putStrLn $ "Nota 3: " ++ show nota3
            let media = (nota1 + nota2 + nota3) / 3
            printf "Média: %.1f\n" media
            if(media>=7) 
                then putStrLn "Aprovado :)"
                else 
                    if(media>=4 && media<=6.9)
                        then putStrLn "Final :|"
                        else putStrLn "Reprovado :("


menuNotas :: String -> String -> String -> IO()
menuNotas disciplina codTurma matriculaAluno = do
    putStrLn("===== ADICIONANDO NOTAS DO ALUNO " ++ matriculaAluno ++ " =====")
    putStrLn " "
    putStrLn "Digite qual nota você quer adicionar: "
    putStrLn "[0] para voltar"
    putStrLn "[1] para adicionar a 1º nota"
    putStrLn "[2] para adicionar a 2º nota"
    putStrLn "[3] para adicionar a 3º nota"
    putStrLn "[4] para ver a situação do aluno" 
    escolha <- getLine
    if (escolha == "0") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4") then do
            putStrLn "Opção Inválida"
            menuNotas disciplina codTurma matriculaAluno
        else do
            if (escolha == "4") then do 
                situacaoAluno disciplina codTurma matriculaAluno
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
    