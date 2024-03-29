module Modules.GerenciadorTurmasController where
import Modules.GerenciadorOpcoesDisciplinaController
import Modules.GerenciadorTurmas
import System.Directory
import System.Console.Pretty
import qualified Data.Char
import Data.Char (toUpper)

opcoesDeTurmas :: String -> IO()
opcoesDeTurmas disciplina = do
    putStrLn (color Magenta . style Bold $ "MENU DE " ++ (map toUpper disciplina) ++ " =====")
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Minhas turmas"
    putStrLn "[2] Criar turma"
    putStrLn "[3] Adicionar aluno"
    putStrLn "[4] Excluir aluno"
    putStrLn "[5] Excluir turma"
    putStrLn (color Magenta "====================")
    escolherOpcaoTurma disciplina

escolherOpcaoTurma :: String -> IO()
escolherOpcaoTurma disciplina = do
    escolha <- getLine
    escolherOpcaoMenuTurmas escolha disciplina
    if (escolha /= "0") then opcoesDeTurmas disciplina
    else putStrLn " "

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStr ""
        | (escolha == "1") = menuMinhasTurmas disciplina
        | (escolha == "2") = criarTurmaController disciplina
        | (escolha == "3") = solicitarEAlocarAlunoController disciplina
        | (escolha == "4") = excluirAlunoController disciplina
        | (escolha == "5") = excluirTurmaController disciplina
        | otherwise = putStrLn "Opção Inválida!"

menuMinhasTurmas :: String -> IO()    
menuMinhasTurmas disciplina = do
    putStrLn ("Turmas de " ++ disciplina)

    response <- listarTurmas disciplina
    putStrLn response

    putStrLn (color Magenta "===============================================")
    putStrLn (color Magenta "Informe um codigo de turma, ou ENTER para sair:")
    codTurma <- getLine

    if codTurma /= "" then do
        validacao <- validarTurma disciplina codTurma

        if not validacao then putStrLn (color Red "Codigo de turma invalido")
        else do 
                Modules.GerenciadorOpcoesDisciplinaController.menuTurmaEscolhida disciplina codTurma
    else putStr ""
 
criarTurmaController :: String -> IO()
criarTurmaController disciplina = do
    putStrLn (color Magenta "CADASTRO DE TURMA")
    putStrLn (color Magenta "Nome da turma: ")
    nome <- getLine
    putStrLn (color Magenta "Codigo da turma: ")
    codTurma <- getLine

    response <- criarTurma disciplina nome codTurma
    putStrLn response

solicitarEAlocarAlunoController :: String -> IO()
solicitarEAlocarAlunoController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma: ")
    codTurma <- getLine

    response <- solicitarEAlocarAluno disciplina codTurma

    if response /= "Código inválido!" then do
        putStrLn (color Magenta "Informe a matricula: ")
        
        m <- getLine
        alocarAlunoController m disciplina codTurma
    else putStrLn ""

alocarAlunoController :: String -> String -> String -> IO()
alocarAlunoController matricula disciplina codTurma = do
    if matricula == "" then putStrLn (color Green "Registro finalizado!")
    else do
        alocarAluno matricula disciplina codTurma

        putStrLn (color Magenta "Informe o proximo aluno (matricula) ou ENTER para finalizar: ")
        m <- getLine
        
        alocarAlunoController m disciplina codTurma

excluirAlunoController :: String -> IO()
excluirAlunoController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma: ")
    codTurma <- getLine
    
    response <- excluirAluno disciplina codTurma
    if response then do 
        putStrLn (color Magenta "Informe a matricula do aluno: ")
        matricula <- getLine

        responseAluno <- removerAluno disciplina matricula codTurma
        putStrLn responseAluno
    else putStrLn (color Red "Turma invalida!")

excluirTurmaController :: String -> IO()
excluirTurmaController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma a ser excluida: ")
    codTurma <- getLine
    response <- excluirTurma disciplina codTurma
    putStrLn response