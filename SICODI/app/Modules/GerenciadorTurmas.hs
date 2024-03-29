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
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)
import Control.Monad (when)
import Data.Bool (Bool)


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
        return "Cadastro concluído!"

    else return "Erro: Código de turma já está em uso."

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

        if not validarExistenciaAluno then return "Aluno nao esta na turma ou nao existe"
        else do
            removeFile diretorioAluno
            return "Aluno removido!"



excluirTurma :: String -> String -> IO String
excluirTurma disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "Turma invalida"
    else do
        removeDirectoryRecursive ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo)
        return "Turma removida!"

solicitarEAlocarAluno :: String -> String -> IO String
solicitarEAlocarAluno disciplina codigo = do
    validarExistencia <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/" ++ codigo ++ ".json")

    if not validarExistencia then return "Codigo invalido!"
    else return ""

alocarAluno :: String -> String -> String -> IO String
alocarAluno matriculaAluno disciplina codigo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codigo ++ "/alunos/" ++ matriculaAluno ++ ".json"
    let diretorioAluno = ("./db/alunos/" ++ matriculaAluno ++ ".json")
    validarMatricula <- doesFileExist ("./db/alunos/" ++ matriculaAluno ++ ".json")

    if not validarMatricula then return "Matricula invalida"
    else do
        createDirectoryIfMissing True $ takeDirectory diretorio
        dadosAluno <- B.readFile diretorioAluno
        case decode dadosAluno of 
            Just (Aluno matricula nome senha turmas) -> do
                let dadosAlunoAtualizado = encode(Aluno {matricula = matricula, nome = nome, senha = senha, turmas = turmas ++ [[disciplina, codigo]]})
                B.writeFile diretorioAluno dadosAlunoAtualizado
                
        let dados = encode (AlunoTurma {faltas = 0, nota1 = 0.0, nota2 = 0.0, nota3 = 0.0, media = 0.0})
        B.writeFile diretorio dados

        return $ "Adicionado " ++ matriculaAluno




