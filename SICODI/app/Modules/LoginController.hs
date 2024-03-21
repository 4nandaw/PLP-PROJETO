module Modules.LoginController where
import Modules.Login
import Modules.MenuProfessor
-- Função para o login geral
loginGeral :: IO ()
loginGeral = do
    putStrLn "Login ======================"
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Login de professor"
    putStrLn "[2] Login de aluno"
    putStrLn "============================="
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
    | otherwise = putStrLn "Opção Inválida" 

loginProfessorController :: IO()
loginProfessorController = do
    putStrLn "Digite o nome da disciplina: "
    nomeDisciplina <- getLine
    putStrLn "Digita a senha: "
    senha <- getLine
    loginValido <- Modules.Login.loginProfessor nomeDisciplina senha
    if (loginValido) then do 
        putStrLn "Login realizado com sucesso!"
        Modules.MenuProfessor.exibirMenuProfessor nomeDisciplina
    else putStrLn "Usuário ou senha inválidos"

loginAlunoController :: IO()
loginAlunoController = do
    putStrLn "Digite a matrícula do aluno: "
    matricula <- getLine
    putStrLn "Digite a senha: "
    senha <- getLine
    loginValido <- Modules.Login.loginAluno matricula senha
    if (loginValido) then do
        putStrLn "Login realizado com sucesso!"     
        putStrLn "EXIBINDO MENU ALUNO | NÃO FEITO AINDA"
    else putStrLn "Usuário ou senha inválidos"
