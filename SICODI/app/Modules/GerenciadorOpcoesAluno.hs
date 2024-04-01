{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorOpcoesAluno where
import Utils.Aluno
import Utils.Avaliacao 
import Modules.GerenciadorOpcoesDisciplina as OpcoesDisciplina
import Data.Aeson
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Console.Pretty
import Data.Char (toUpper)
import System.Directory (doesFileExist)


listarDisciplinasTurmas :: String -> IO String
listarDisciplinasTurmas matricula = do
    let diretorio = "./db/alunos/" ++ matricula ++ ".json"
    aluno <- B.readFile diretorio
    case decode aluno of
        Just (Aluno _ _ _ turmas) -> do
            let listaDiscipinasTurmas = map (\x -> ajustarExibirDisciplinaTurma x) turmas
            return $ unlines $ listaDiscipinasTurmas
        Nothing -> return (color Red "Erro.")

ajustarExibirDisciplinaTurma :: [String] -> String
ajustarExibirDisciplinaTurma [disciplina, turma] = (color White . style Bold $ "Disciplina: ") ++ disciplina ++ (color White . style Bold $ ". Turma: ") ++ turma

turmaValida :: String -> String -> String -> IO Bool
turmaValida matricula disciplina turma = do
     let diretorio = "./db/alunos/" ++ matricula ++ ".json"
     aluno <- B.readFile diretorio
     case decode aluno of 
        Just (Aluno _ _ _ turmas) -> do
            if (elem [disciplina, turma] turmas) then return True
            else return False

acessarChatAluno :: String -> String -> String -> IO String
acessarChatAluno matricula disciplina turma = do
    chat <- OpcoesDisciplina.acessarChat disciplina turma matricula
    return chat


visualizarNotas :: String -> String -> String -> IO String
visualizarNotas matricula disciplina codTurma = do
    situacao <- OpcoesDisciplina.situacaoAluno disciplina codTurma matricula
    return situacao
                    
salvarAvaliacao :: String -> Int -> String -> String -> IO String
salvarAvaliacao diretorio nota comentario matricula = do
    let diretorioAvaliacao = diretorio ++ matricula ++ ".json"
    let dados = encode (Avaliacao {nota = nota, comentario = comentario})
    B.writeFile diretorioAvaliacao dados
    return (color Green "\nAvaliação registrada!")

exibirRespostasCertas :: String -> String -> String -> [Bool] -> IO String
exibirRespostasCertas disciplina codTurma titulo listaRespostasAluno = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
    dados <- B.readFile diretorio
    case decode dados of
        Just (Quiz perguntas respostas) -> do
            let respostasFormatadas = zipWith3 ajustarResposta perguntas respostas listaRespostasAluno
            return $ unlines respostasFormatadas
        Nothing -> return "Erro ao ler dados do quiz."    

ajustarResposta :: String -> Bool -> Bool -> String
ajustarResposta pergunta respostaBool respostaAlunoBool = do
    let respostaAluno = formatarBool respostaAlunoBool
        resposta = formatarBool respostaBool
        acertou = respostaBool == respostaAlunoBool
    if acertou then "\n" ++ (color Blue pergunta) ++ "\n" ++ (color White "Sua resposta: ") ++ respostaAluno ++ "\n" ++ (color White "Resposta certa: ") ++ resposta ++ "\n" ++ color Green "Acertou!"
    else "\n" ++ (color Blue pergunta) ++ "\n" ++ (color White "Sua resposta: ") ++ respostaAluno ++ "\n" ++ (color White "Resposta certa: ") ++ resposta ++ "\n" ++ color Red "Errou!"

formatarBool :: Bool -> String
formatarBool boolean = 
    if boolean then "Correto"
    else "Incorreto"

validarTituloQuiz :: String -> String -> String ->  IO Bool
validarTituloQuiz disciplina codTurma titulo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
    quizValido <- doesFileExist diretorio
    return quizValido

getHead :: [String] -> String
getHead (h:_) = h

getTail :: [String] -> [String]
getTail (_:t) = t

validarResposta :: String -> Bool
validarResposta resposta
    | map toUpper resposta == "V" || map toUpper resposta == "F" = True
    | otherwise = False

pegarRespostaAlunoBool :: String -> Bool
pegarRespostaAlunoBool resposta
    | (map toUpper resposta == "V") = True
    | (otherwise) = False    

perguntasQuiz :: String -> String -> String -> IO [String]
perguntasQuiz disciplina codTurma titulo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
    dados <- B.readFile diretorio
    case decode dados of
        Just (Quiz perguntas _) -> return perguntas
                              

