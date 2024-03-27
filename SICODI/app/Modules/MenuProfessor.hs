module Modules.MenuProfessor where 
import Modules.GerenciadorTurmasController
import Modules.GerenciadorOpcoesDisciplina
import Modules.GerenciadorOpcoesDisciplinaController
import System.Console.Pretty

escolherOpcaoProfessor :: String -> IO()
escolherOpcaoProfessor disciplina = do
    escolha <- getLine
    escolherValorOpcao escolha disciplina
    if (escolha /= "0") then exibirMenuProfessor disciplina
    else putStrLn " "
    
exibirMenuProfessor :: String -> IO()
exibirMenuProfessor disciplina = do
    putStrLn (color Magenta . style Bold $ "MENU DE " ++ disciplina)
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Opcoes da disciplina"
    putStrLn "[2] Configuracoes de turmas"
    putStrLn (color Magenta . style Bold $ "=============================")
    escolherOpcaoProfessor disciplina

escolherValorOpcao :: String -> String -> IO()
escolherValorOpcao escolha disciplina
        | (escolha == "0") = putStrLn (color Green "Saindo da conta...")
        | (escolha == "1") = Modules.GerenciadorOpcoesDisciplinaController.menuDeDisciplina disciplina
        | (escolha == "2") = opcoesDeTurmas disciplina
        | otherwise = putStrLn (color Red "Opção Inválida!")
       