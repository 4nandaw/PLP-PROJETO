module Modules.MenuPrincipal where 
import Modules.Cadastro
import Modules.Login
import Modules.LoginController
import Modules.CadastroController
import System.Console.Pretty

escolherOpcao :: IO()
escolherOpcao = do
    escolha <- getLine
    escolher escolha
    if (escolha /= "0") then printarMenu
    else putStrLn " "
    
printarMenu :: IO()
printarMenu = do
    putStrLn (color Yellow . style Bold $ "\nMENU INICIAL =======")
    putStrLn (color Yellow "Digite uma opção: ")
    putStrLn "[0] Sair"
    putStrLn "[1] Login"
    putStrLn "[2] Cadastro"
    putStrLn (color Yellow . style Bold $ "====================")
    escolherOpcao

escolher :: String -> IO()
escolher escolha 
        | (escolha == "0") = putStr (color Green "Programa finalizado!")
        | (escolha == "1") = Modules.LoginController.loginGeral
        | (escolha == "2") = Modules.CadastroController.cadastroGeral
        | otherwise = putStrLn (color Red "Opção Inválida!")
       