module Modules.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno
import Modules.GerenciadorOpcoesDisciplina
import Modules.GerenciadorOpcoesDisciplinaController
import System.Console.Pretty

import Modules.Chat


chatAlunoController :: String -> String -> String -> IO()
chatAlunoController matricula disciplina turma = do
    putStrLn ""
    putStrLn (color Red "AVISO: " ++ color White "se você deseja sair do chat, basta dar ENTER a qualquer momento da conversa.\n")
    putStrLn (color Blue . style Bold $ "Mensagens anteriores: ")
    chat <- Modules.GerenciadorOpcoesAluno.acessarChatAluno matricula disciplina turma
    putStrLn chat

    enviarMensagemAlunoController disciplina turma matricula

enviarMensagemAlunoController :: String -> String -> String -> IO()
enviarMensagemAlunoController disciplina codTurma matriculaAluno = do
    msg <- getLine

    remetente <- lerNomeAluno matriculaAluno

    if msg /= "" then do 
        enviarMensagem disciplina codTurma remetente matriculaAluno msg
        enviarMensagemAlunoController disciplina codTurma matriculaAluno
    else putStrLn (color Blue . style Bold $ "====================")

menuTurmaAluno :: String -> String -> String -> IO()
menuTurmaAluno matricula disciplina turma = do
    let msg = "\n===== Menu do aluno " ++ matricula ++ ", na disciplina " ++ disciplina ++ " e turma " ++ turma ++ "! ====="
    putStrLn (color Blue . style Bold $ msg)
    putStrLn (color Blue "Digite uma opção:")
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver notas"
    putStrLn "[2] Ver Mural"
    putStrLn "[3] Chat"
    putStrLn "[4] Avaliar professor(a)"
    putStrLn "[5] Materiais Didáticos"
    putStrLn (color Blue . style Bold $ "==============================================================")
    escolherOpcaoAluno matricula disciplina turma

escolherOpcaoAluno :: String -> String -> String -> IO()
escolherOpcaoAluno matricula disciplina turma = do 
    escolha <- getLine
    escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
    if (escolha /= "0") then menuTurmaAluno matricula disciplina turma 
    else putStrLn " "

escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn ""
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | (escolha == "2") = exibirMuralAlunoController disciplina turma
        | (escolha == "3") = chatAlunoController matricula disciplina turma
        | (escolha == "4") = menuAvaliacoes matricula disciplina turma
        | (escolha == "5") = Modules.GerenciadorOpcoesDisciplinaController.exibirMaterialDidaticoController disciplina turma
        | otherwise = putStrLn (color Red "\nOpção inválida.")

visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao

exibirMuralAlunoController :: String -> String -> IO()
exibirMuralAlunoController disciplina codTurma = do
    avisos <- Modules.GerenciadorOpcoesDisciplina.exibirAvisosMural disciplina codTurma
    putStrLn avisos

menuAvaliacoes :: String -> String -> String -> IO()
menuAvaliacoes matricula disciplina turma = do
    putStrLn (color Blue . style Bold $ "\nAVALIAÇÃO DE DESEMPENHO DO PROFESSOR =====")
    putStrLn (color Blue "Digite uma opção ou ENTER para sair: ")
    putStrLn ("[1] Péssimo")
    putStrLn ("[2] Ruim")
    putStrLn ("[3] Ok")
    putStrLn ("[4] Bom")
    putStrLn ("[5] Excelente")
    putStrLn (color Blue . style Bold $  "==========================================")
    escolha <- getLine
    
    let nota = (read escolha :: Int)

    if (escolha == "") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4" && escolha /= "5") then do
            putStrLn (color Red "\nOpção inválida.")
        else
            escolherOpcaoAvaliacao matricula disciplina turma nota

escolherOpcaoAvaliacao :: String -> String -> String -> Int -> IO()
escolherOpcaoAvaliacao matricula disciplina turma nota = do
    putStrLn (color Blue "\nComentário: ")
    comentario <- getLine
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/avaliacoes/"
    avaliacaoSave <- Modules.GerenciadorOpcoesAluno.salvarAvaliacao diretorio nota comentario matricula
    putStrLn avaliacaoSave
