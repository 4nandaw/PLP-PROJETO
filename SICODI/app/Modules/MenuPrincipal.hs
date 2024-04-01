module Modules.MenuPrincipal where 
import Modules.Cadastro
import Modules.Login
import Modules.Controllers.LoginController
import Modules.Controllers.CadastroController
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
        | (escolha == "0") = putStr (color Green "\nPrograma finalizado!\n")
        | (escolha == "1") = Modules.Controllers.LoginController.loginGeral
        | (escolha == "2") = Modules.Controllers.CadastroController.cadastroGeral
        | otherwise = putStrLn (color Red "Opção Inválida!")
       