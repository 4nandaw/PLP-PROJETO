module Modules.Cadastro where

cadastroProfessor :: IO()
cadastroAluno :: IO()
escolherCadastro :: String -> IO()
escolherOpcaoCadastro :: IO()
cadastroGeral :: IO()

cadastroGeral = do
    putStrLn "CADASTRO ====================="
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Cadastro de professor"
    putStrLn "[2] Cadastro de aluno"
    putStrLn "=============================="
    escolherOpcaoCadastro

escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroProfessor
    | (escolha == "2") = cadastroAluno
    | otherwise = putStrLn "Opção Inválida" 
    
cadastroProfessor = do
    putStrLn "CADASTRO DE PROFESSOR"
    putStrLn "Nome: "
    nome <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine
    putStrLn "Nome da disciplina: "
    nomeDaDisciplina <- getLine
    putStrLn "Cadastro concluído!"
    putStrLn " "
    writeFile ("../db/professor/" ++ matricula ++ ".txt") (
        "nome: " ++ nome ++ "\n" ++
        "matricula: " ++ matricula ++ "\n" ++
        "senha: " ++ senha ++ "\n" ++
        "disciplina: " ++ nomeDaDisciplina ++ "")

cadastroAluno = do
    putStrLn "CADASTRO DE ALUNO"
    putStrLn "Nome: "
    nome <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine
    putStrLn "Cadastro concluído!"
    putStrLn " "
    writeFile ("../db/aluno/" ++ matricula ++ ".txt") (
        "nome: " ++ nome ++ "\n" ++
        "matricula: " ++ matricula ++ "\n" ++
        "senha: " ++ senha ++ "")
    