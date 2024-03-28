module Modules.LoginController where
import Modules.Login
import Modules.MenuAluno
import Modules.GerenciadorTurmasController
import System.Console.Pretty

-- Função para o login geral
loginGeral :: IO ()
loginGeral = do
    putStrLn (color Yellow "Login ======================")
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Login de professor"
    putStrLn "[2] Login de aluno"
    putStrLn (color Yellow "=============================")
    escolherOpcaoLogin

-- Função para escolher a opção de login
escolherOpcaoLogin :: IO ()
escolherOpcaoLogin = do
    escolha <- getLine 
    escolherLogin escolha

-- Função para realizar o login
escolherLogin :: String -> IO ()
escolherLogin escolha 
    | escolha == "0" = putStr ""
    | escolha == "1" = loginProfessorController
    | escolha == "2" = loginAlunoController
    | otherwise = putStrLn (color Red "Opção Inválida" )

loginProfessorController :: IO()
loginProfessorController = do
    putStrLn (color Yellow "Digite o nome da disciplina: ")
    nomeDisciplina <- getLine
    putStrLn (color Yellow "Digita a senha: ")
    senha <- getLine
    loginValido <- Modules.Login.loginProfessor nomeDisciplina senha
    if (loginValido) then do 
        putStrLn (color Green "\nLogin realizado com sucesso!\n")
        Modules.GerenciadorTurmasController.opcoesDeTurmas nomeDisciplina
    else putStrLn (color Red "Usuário ou senha inválidos")

loginAlunoController :: IO()
loginAlunoController = do
    putStrLn (color Yellow"Digite a matrícula do aluno: ")
    matricula <- getLine
    putStrLn (color Yellow "Digite a senha: ")
    senha <- getLine
    loginValido <- Modules.Login.loginAluno matricula senha
    if (loginValido) then do
        putStrLn (color Green "\nLogin realizado com sucesso!\n")
        Modules.MenuAluno.exibirMenuAluno matricula
    else putStrLn (color Red "Usuário ou senha inválidos")