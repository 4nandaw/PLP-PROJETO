module Modules.GerenciadorTurmasController where

import Modules.GerenciadorTurmas

opcoesDeTurmas :: String -> IO()
opcoesDeTurmas disciplina = do
    putStrLn "MENU DE TURMAS ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Minhas turmas"
    putStrLn "[2] Criar turma"
    putStrLn "[3] Adicionar aluno"
    putStrLn "[4] Excluir aluno"
    putStrLn "[5] Excluir turma"
    putStrLn "===================="
    escolherOpcaoTurma disciplina

escolherOpcaoTurma :: String -> IO()
escolherOpcaoTurma disciplina = do
    escolha <- getLine
    escolherOpcaoMenuTurmas escolha disciplina
    if (escolha /= "0") then opcoesDeTurmas disciplina
    else putStrLn " "

listarTurmasController :: IO ()    
listarTurmasController disciplina = do
    putStrLn ("Turmas de " ++ disciplina)

    putStrLn $ listarTurmas disciplina

    putStrLn "==============================================="
    putStrLn "Informe um codigo de turma, ou ENTER para sair:"
    codigo <- getLine

    if codigo /= "" then verAlunos (diretorio ++ codigo ++ "/alunos/")
    else putStrLn "" 

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = listarTurmasController disciplina
        | (escolha == "2") = criarTurma disciplina
        | (escolha == "3") = solicitarEAlocarAluno disciplina
        | (escolha == "4") = excluirAluno disciplina
        | (escolha == "5") = excluirTurma disciplina
        | otherwise = putStrLn "Opção Inválida!!"