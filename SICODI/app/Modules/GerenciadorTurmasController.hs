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

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = menuMinhasTurmas disciplina
        | (escolha == "2") = criarTurmaController disciplina
        | (escolha == "3") = solicitarEAlocarAlunoController disciplina
        | (escolha == "4") = excluirAlunoController disciplina
        | (escolha == "5") = excluirTurmaController disciplina
        | otherwise = putStrLn "Opção Inválida!!"

menuMinhasTurmas :: String -> IO()    
menuMinhasTurmas disciplina = do
    putStrLn ("Turmas de " ++ disciplina)

    response <- listarTurmas disciplina
    putStrLn response

    putStrLn "==============================================="
    putStrLn "Informe um codigo de turma, ou ENTER para sair:"
    codigo <- getLine

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    validarTurma <- doesFileExist (diretorio ++ codigo ++ "/" ++ codigo ++ ".json") 
    
    if not validarTurma then putStrLn "Codigo de turma invalido"
    else do 
        if codigo /= "" then do
            putStrLn "Escolha uma opção: "
            putStrLn "[1] Ver alunos da turma"
            putStrLn "[2] Ver relatório da turma"
            putStrLn "[3] Ver avaliações"
            putStrLn "[4] Mural da Turma"
            putStrLn "==============================================="
            opcao <- getLine

            if codigo /= "" then do
                if opcao == "1" then do
                    responseAlunos <- verAlunos (diretorio ++ codigo ++ "/alunos/")
                    putStrLn responseAlunos
                else if opcao == "2" then do
                    exibirRelatorio (diretorio ++ codigo ++ "/alunos/")
                else if opcao == "3" then do
                    exibirAvaliacoes (diretorio ++ codigo ++ "/avaliacoes/")
                else putStrLn "Opção inválida!"
            else putStrLn ""
        else putStrLn "" 

exibirRelatorio :: String -> IO()
exibirRelatorio diretorio = do
    mediaF <- mediaFaltas diretorio
    mediaN <- mediaNotas diretorio
    putStrLn "\nRELATÓRIO DA TURMA ============================\n"
    putStrLn mediaN
    putStrLn ""
    putStrLn mediaF
    putStrLn "\n==============================================="

exibirAvaliacoes :: String -> IO()
exibirAvaliacoes diretorio = do
    media <- mediaAvaliacoes diretorio
    feedbacks <- verAvaliacoes diretorio
    putStrLn "\nAVALIAÇÕES ===================================="
    putStrLn $ "\n" ++ media
    putStrLn feedbacks
    putStrLn "==============================================="

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

        putStrLn "Informe o proximo aluno (matricula) ou ENTER para finalizar: "
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