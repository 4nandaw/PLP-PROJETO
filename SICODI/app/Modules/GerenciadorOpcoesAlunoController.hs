module Modules.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno
import Modules.Chat

visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao

chatController :: String -> String -> String -> IO()
chatController matricula disciplina turma = do
    putStrLn "Mensagens anteriores: "
    chat <- Modules.GerenciadorOpcoesAluno.acessarChatAluno matricula disciplina turma
    putStrLn chat

    enviarMensagemController disciplina turma matricula

enviarMensagemController :: String -> String -> String -> IO()
enviarMensagemController disciplina codTurma matriculaAluno = do
    putStrLn ":"
    msg <- getLine

    if msg /= "" then do 
        enviarMensagem disciplina codTurma matriculaAluno matriculaAluno msg
        enviarMensagemController disciplina codTurma matriculaAluno
    else putStrLn "===================="

escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | (escolha == "2") = chatController matricula disciplina turma
        | otherwise = putStrLn "Opção Inválida!!"


escolherOpcaoAluno :: String -> String -> String -> IO()
escolherOpcaoAluno matricula disciplina turma = do 
    escolha <- getLine
    escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
    if (escolha /= "0") then menuTurmaAluno matricula disciplina turma 
    else putStrLn " "

menuTurmaAluno :: String -> String -> String -> IO()
menuTurmaAluno matricula disciplina turma = do
    putStrLn ("===== Menu do aluno " ++ matricula ++ ", na disciplina " ++ disciplina ++ " e turma " ++ turma ++ "! =====")
    putStrLn "Digite [0] para voltar"
<<<<<<< HEAD
    putStrLn "Digite [1] para ver sua situação atual (notas, faltas e média na turma)"
=======
    putStrLn "Digite [1] para ver suas notas"
    putStrLn "Digite [2] para chat"
>>>>>>> 3e22487 (envio de mensagem pelo chat)
    escolherOpcaoAluno matricula disciplina turma