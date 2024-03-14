module Modules.MenuPrincipal where 
import Modules.Cadastro
import Modules.MenuProfessor
import Modules.Login

escolherOpcao :: IO()
escolherOpcao = do
    escolha <- getLine
    escolher escolha
    if (escolha /= "0") then printarMenu
    else putStrLn " "
    
printarMenu :: IO()
printarMenu = do
    putStrLn "MENU INICIAL ======="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Sair"
    putStrLn "[1] Login"
    putStrLn "[2] Cadastro"
    putStrLn "===================="
    escolherOpcao

escolher :: String -> IO()
escolher escolha 
        | (escolha == "0") = putStrLn "Programa finalizado"
        | (escolha == "1") = Modules.Login.loginGeral
        | (escolha == "2") = Modules.Cadastro.cadastroGeral
        | otherwise = putStrLn "Opção Inválida!!"
       