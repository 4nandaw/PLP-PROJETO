{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorTurmas where

import Utils.Aluno
import Utils.AlunoTurma
import Utils.Avaliacao
import Utils.Mural
import Utils.Turma
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import Data.Char (isSpace)
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)
import Control.Monad (when)
import Data.List (intercalate)
import Data.Bool (Bool)
import System.Console.Pretty

listarTurmas :: String -> IO String
listarTurmas disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    createDirectoryIfMissing True $ takeDirectory diretorio

    listaDeTurmas <- getDirectoryContents diretorio

    response <- mapM (\x -> (ajustarExibirTurmas x disciplina)) listaDeTurmas

    return (unlines $ response)

ajustarExibirTurmas :: String -> String -> IO String
ajustarExibirTurmas turma disciplina = do
    if turma /= "." && turma /= ".." then do
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/alunos/"

        createDirectoryIfMissing True $ takeDirectory diretorio

        listaDeAlunos <- getDirectoryContents diretorio
        let numAlunos = (length listaDeAlunos) - 2

        return (turma ++ " ------ " ++ (show numAlunos) ++ " aluno(s)")
    else return ""
    
criarTurma :: String -> String -> String -> IO String
criarTurma disciplina nome codigo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json"
    let avaliacoes = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/avaliacoes/"
    let mural = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/mural/"

    validarUnico <- doesFileExist diretorio

    if not validarUnico then do
        createDirectoryIfMissing True $ takeDirectory diretorio
        createDirectoryIfMissing True $ takeDirectory avaliacoes
        createDirectoryIfMissing True $ takeDirectory mural

        let dados = encode (Turma {nome = nome, codigo = codigo, alunos = []})
        B.writeFile diretorio dados
        return (color Green "\nCadastro concluído!\n")

    else return (color Red "\nErro: Código de turma já está em uso.")

validarTurma :: String -> String -> IO Bool
validarTurma disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    validacao <- doesFileExist (diretorio ++ codTurma ++ "/" ++ codTurma ++ ".json") 

    return validacao

excluirAluno :: String ->  String -> IO Bool
excluirAluno disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return False
    else return True

removerAluno :: String -> String -> String -> IO String
removerAluno disciplina matricula codigo = do
        let diretorioAluno = ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matricula ++ ".json")

        validarExistenciaAluno <- doesFileExist diretorioAluno

        if not validarExistenciaAluno then return (color Red "\nAluno não está na turma ou não existe\n")
        else do
            removeFile diretorioAluno
            return (color Green "\nAluno removido!\n")

excluirTurma :: String -> String -> IO String
excluirTurma disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "\n Turma inválida."
    else do
        removeDirectoryRecursive ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo)
        return (color Green "\nTurma removida!\n")

solicitarEAlocarAluno :: String -> String -> IO String
solicitarEAlocarAluno disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return (color Red "\nCódigo inválido.")
    else return ""

verificarAlunoJaEstaNaTurma :: String -> String -> String -> IO Bool
verificarAlunoJaEstaNaTurma matriculaAluno disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/" ++ codTurma ++ ".json"
    dados <- B.readFile diretorio
    case decode dados of
        Just (Turma _ _ alunos) -> do
            if elem matriculaAluno alunos then return True
            else return False
        Nothing -> return False

alocarAluno :: String -> String -> String -> IO String
alocarAluno matriculaAluno disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json"
    let diretorioAluno = ("./db/alunos/" ++ matriculaAluno ++ ".json")
    let diretorioTurma = "./db/disciplinas/" ++ disciplina ++ "/turmas/"++ codTurma ++ "/" ++ codTurma ++ ".json"
    validarMatricula <- doesFileExist ("./db/alunos/" ++ matriculaAluno ++ ".json")

    if not validarMatricula then return (color Red "\nMatricula inválida.")
    else do
        alunoJaEstaNaTurma <- verificarAlunoJaEstaNaTurma matriculaAluno disciplina codTurma
        if alunoJaEstaNaTurma then return (color Red "Aluno já está alocado nessa turma.")
        else do 
            createDirectoryIfMissing True $ takeDirectory diretorio
            dadosAluno <- B.readFile diretorioAluno
            
            case decode dadosAluno of 
                Just (Aluno matricula nome senha turmas) -> do
                    let dadosAlunoAtualizado = encode(Aluno {matricula = matricula, nome = nome, senha = senha, turmas = turmas ++ [[disciplina, codTurma]]})
                    B.writeFile diretorioAluno dadosAlunoAtualizado
    
            let dados = encode (AlunoTurma {faltas = 0, nota1 = 0.0, nota2 = 0.0, nota3 = 0.0, media = 0.0})
            B.writeFile diretorio dados

            dadosTurma <- B.readFile diretorioTurma
            
            case decode dadosTurma of
                Just (Turma nome codigo alunos) -> do
                    let dadosTurmaAtualizado = encode(Turma {nome = nome, codigo = codigo, alunos = alunos ++ [matriculaAluno]})
                    B.writeFile diretorioTurma dadosTurmaAtualizado

            return $ (color Green "\nAluno ") ++ matriculaAluno ++ (color Green " adicionado")

validandoString :: String -> Bool  
validandoString string = not (all isSpace string || null string)

validandoDadosTurma :: String -> String -> Bool
validandoDadosTurma nome codTurma = do
    let valido = validandoString nome && validandoString codTurma
    if valido then True
    else False