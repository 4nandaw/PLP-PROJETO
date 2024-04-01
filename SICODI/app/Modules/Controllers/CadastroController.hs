module Modules.Controllers.CadastroController where
import Modules.Cadastro
import System.Console.Pretty

cadastroDisciplinaController :: IO()
cadastroDisciplinaController = do
    putStrLn (color Yellow . style Bold $ "\nCADASTRO DE DISCIPLINA")
    putStrLn (color Yellow "\nNome do professor: ")
    nomeProfessor <- getLine
    putStrLn (color Yellow "\nMatrícula: ")
    matricula <- getLine
    putStrLn (color Yellow "\nSenha: ")
    senha <- getLine
    putStrLn (color Yellow "\nNome da disciplina: ")
    nomeDisciplina <- getLine
    let dadosValidos = Modules.Cadastro.validandoDadosProfessor  nomeProfessor matricula senha nomeDisciplina
    if dadosValidos then do
        cadastroValido <- Modules.Cadastro.cadastroDisciplina nomeProfessor matricula senha nomeDisciplina
        if (cadastroValido) 
            then putStrLn (color Green "\nCadastro concluído!")
            else putStrLn (color Red "\nNome de disciplina já está em uso.")
    else putStrLn $ color Red "\nDádos inválidos, não coloque dados brancos ou nulos!"

cadastroAlunoController :: IO()
cadastroAlunoController = do
    putStrLn (color Yellow . style Bold $ "\nCADASTRO DE ALUNO")
    putStrLn (color Yellow "\nNome: ")
    nome <- getLine
    putStrLn (color Yellow "\nMatrícula: ")
    matricula <- getLine
    putStrLn (color Yellow "\nSenha: ")
    senha <- getLine
    let dadosValidos = Modules.Cadastro.validandoDadosAluno nome matricula senha 
    if dadosValidos then do    
        cadastroValido <- Modules.Cadastro.cadastroAluno nome matricula senha
        if(cadastroValido)
            then putStrLn (color Green "\nCadastro concluído!")
            else putStrLn (color Red "\nMatrícula já está em uso.")
     else putStrLn $ color Red "\nDádos inválidos, não coloque dados brancos ou nulos."

escolherOpcaoCadastro :: IO()
escolherOpcaoCadastro = do
    escolha <- getLine
    escolherCadastro escolha

escolherCadastro :: String -> IO()
escolherCadastro escolha 
    | (escolha == "0") = putStr ""
    | (escolha == "1") = cadastroDisciplinaController
    | (escolha == "2") = cadastroAlunoController
    | otherwise = putStrLn (color Red "Opção inválida.")

cadastroGeral :: IO()
cadastroGeral = do
    putStrLn (color Yellow . style Bold $ "\nCADASTRO =====================")
    putStrLn (color Yellow "Digite uma opção: ")
    putStrLn "[0] Voltar pro menu inicial"
    putStrLn "[1] Cadastro de professor"
    putStrLn "[2] Cadastro de aluno"
    putStrLn (color Yellow . style Bold $ "==============================")
    escolherOpcaoCadastro