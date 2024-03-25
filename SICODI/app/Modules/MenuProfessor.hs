module Modules.MenuProfessor where 
import Modules.GerenciadorTurmasController
import Modules.GerenciadorOpcoesDisciplina
import Modules.GerenciadorOpcoesDisciplinaController

escolherOpcaoProfessor :: String -> IO()
escolherOpcaoProfessor disciplina = do
    escolha <- getLine
    escolherValorOpcao escolha disciplina
    if (escolha /= "0") then exibirMenuProfessor disciplina
    else putStrLn " "
    
exibirMenuProfessor :: String -> IO()
exibirMenuProfessor disciplina = do
    putStrLn ("MENU DE " ++ disciplina)
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Opcoes da disciplina"
    putStrLn "[2] Configuracoes de turmas"
    putStrLn "============================="
    escolherOpcaoProfessor disciplina

escolherValorOpcao :: String -> String -> IO()
escolherValorOpcao escolha disciplina
        | (escolha == "0") = putStrLn "Saindo da conta..."
        | (escolha == "1") = Modules.GerenciadorOpcoesDisciplinaController.menuDeDisciplina disciplina
        | (escolha == "2") = opcoesDeTurmas disciplina
        | otherwise = putStrLn "Opção Inválida!!"
       