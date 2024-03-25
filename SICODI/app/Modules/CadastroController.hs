module Modules.CadastroController where
import Modules.Cadastro

cadastroDisciplinaController :: IO()
cadastroDisciplinaController = do
    putStrLn "CADASTRO DE DISCIPLINA"
    putStrLn "Nome do professor: "
    nomeProfessor <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine
    putStrLn "Nome da disciplina: "
    nomeDisciplina <- getLine
    cadastroValido <- Modules.Cadastro.cadastroDisciplina nomeProfessor matricula senha nomeDisciplina
    if (cadastroValido) 
        then putStrLn "CADASTRO CONCLUÍDO :)"
        else putStrLn "Nome de disciplina já está em uso"

cadastroAlunoController :: IO()
cadastroAlunoController = do
    putStrLn "CADASTRO DE ALUNO"
    putStrLn "Nome: "
    nome <- getLine
    putStrLn "Matrícula: "
    matricula <- getLine
    putStrLn "Senha: "
    senha <- getLine    
    cadastroValido <- Modules.Cadastro.cadastroAluno nome matricula senha
    if(cadastroValido)
        then putStrLn "CADASTRO CONCLUÍDO"
        else putStrLn "Matrícula já está em uso"

escolherOpcaoCadastro :: IO()
escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro :: String -> IO()
escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroDisciplinaController
    | (escolha == "2") = cadastroAlunoController
    | otherwise = putStrLn "Opção Inválida" 

cadastroGeral :: IO()
cadastroGeral = do
    putStrLn "CADASTRO ====================="
    putStrLn "Digite uma opção: "       
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Cadastro de professor"
    putStrLn "[2] Cadastro de aluno"
    putStrLn "=============================="
    escolherOpcaoCadastro