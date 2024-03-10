module Modules.Cadastro where
import System.Directory (createDirectoryIfMissing)
import System.FilePath.Posix (takeDirectory)


cadastroProfessor :: IO()
escolherCadastro :: String -> IO()
escolherOpcaoCadastro :: IO()
cadastroGeral :: IO()


cadastroGeral = do
    putStrLn "CADASTRO"
    putStrLn "Digite uma opção: "
    putStrLn "[0] para voltar pro menu inicial"
    putStrLn "[1] para cadastro de professor"
    putStrLn "[2] para cadastro de aluno"
    escolherOpcaoCadastro

escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroProfessor
    | (escolha == "2") = putStrLn "CadastroAluno"
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
    