module Modules.GerenciadorTurmasController where

import Modules.GerenciadorTurmas
import System.Directory

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

listarTurmasController :: String -> IO()    
listarTurmasController disciplina = do
    putStrLn ("Turmas de " ++ disciplina)

    response <- listarTurmas disciplina
    putStrLn response

    putStrLn "==============================================="
    putStrLn "Informe um codigo de turma, ou ENTER para sair:"
    codigo <- getLine

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    if codigo /= "" then do
        validarTurma <- doesFileExist (diretorio ++ codigo ++ "/" ++ codigo ++ ".json") 

        if not validarTurma then putStrLn "Codigo de turma invalido"
        else do 
            responseAlunos <- verAlunos (diretorio ++ codigo ++ "/alunos/")
            putStrLn responseAlunos

    else putStrLn "" 

criarTurmaController :: String -> IO()
criarTurmaController disciplina = do
    putStrLn "CADASTRO DE TURMA"
    putStrLn "Nome da turma: "
    nome <- getLine
    putStrLn "Codigo da turma: "
    codigo <- getLine

    response <- criarTurma disciplina nome codigo
    putStrLn response

solicitarEAlocarAlunoController :: String -> IO()
solicitarEAlocarAlunoController disciplina = do
    putStrLn "Informe o codigo da turma: "
    codigo <- getLine

    response <- solicitarEAlocarAluno disciplina codigo

    if response /= "Codigo invalido!" then do
        putStrLn "Informe a matricula: "
        m <- getLine
        alocarAlunoController m disciplina codigo
    else putStrLn ""

alocarAlunoController :: String -> String -> String -> IO()
alocarAlunoController matricula disciplina codigo = do
    if matricula == "" then putStrLn "Registro finalizado!"
    else do
        alocarAluno matricula disciplina codigo

        putStrLn "Informe o proximo aluno (matricula): "
        m <- getLine
        
        alocarAlunoController m disciplina codigo

excluirAlunoController :: String -> IO()
excluirAlunoController disciplina = do
    putStrLn "Informe o codigo da turma: "
    codigo <- getLine
    
    response <- excluirAluno disciplina codigo

    if response /= "Turma invalida!" then do 
        putStrLn "Informe a matricula do aluno: "
        matricula <- getLine

        responseAluno <- removerAluno disciplina matricula codigo
        putStrLn responseAluno
    else putStrLn "Turma invalida!"

excluirTurmaController :: String -> IO()
excluirTurmaController disciplina = do
    putStrLn "Informe o codigo da turma a ser excluida: "
    codigo <- getLine

    response <- excluirTurma disciplina codigo
    putStrLn response

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = listarTurmasController disciplina
        | (escolha == "2") = criarTurmaController disciplina
        | (escolha == "3") = solicitarEAlocarAlunoController disciplina
        | (escolha == "4") = excluirAlunoController disciplina
        | (escolha == "5") = excluirTurmaController disciplina
        | otherwise = putStrLn "Opção Inválida!!"