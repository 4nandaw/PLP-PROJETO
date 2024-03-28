module Modules.CadastroController where
import Modules.Cadastro
import System.Console.Pretty

cadastroDisciplinaController :: IO()
cadastroDisciplinaController = do
    putStrLn (color Yellow . style Bold $ "CADASTRO DE DISCIPLINA")
    putStrLn (color Yellow "Nome do professor: ")
    nomeProfessor <- getLine
    putStrLn (color Yellow "Matrícula: ")
    matricula <- getLine
    putStrLn (color Yellow "Senha: ")
    senha <- getLine
    putStrLn (color Yellow "Nome da disciplina: ")
    nomeDisciplina <- getLine
    cadastroValido <- Modules.Cadastro.cadastroDisciplina nomeProfessor matricula senha nomeDisciplina
    if (cadastroValido) 
        then putStrLn (color Green "CADASTRO CONCLUÍDO :)")
        else putStrLn (color Red "Nome de disciplina já está em uso")

cadastroAlunoController :: IO()
cadastroAlunoController = do
    putStrLn (color Yellow . style Bold $ "CADASTRO DE ALUNO")
    putStrLn (color Yellow "Nome: ")
    nome <- getLine
    putStrLn (color Yellow "Matrícula: ")
    matricula <- getLine
    putStrLn (color Yellow "Senha: ")
    senha <- getLine    
    cadastroValido <- Modules.Cadastro.cadastroAluno nome matricula senha
    if(cadastroValido)
        then putStrLn (color Green "CADASTRO CONCLUÍDO")
        else putStrLn (color Red "Matrícula já está em uso")

escolherOpcaoCadastro :: IO()
escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro :: String -> IO()
escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroDisciplinaController
    | (escolha == "2") = cadastroAlunoController
    | otherwise = putStrLn (color Red "Opção Inválida")

cadastroGeral :: IO()
cadastroGeral = do
    putStrLn (color Yellow . style Bold $ "CADASTRO =====================")
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Cadastro de professor"
    putStrLn "[2] Cadastro de aluno"
    putStrLn (color Yellow . style Bold $ "==============================")
    escolherOpcaoCadastro