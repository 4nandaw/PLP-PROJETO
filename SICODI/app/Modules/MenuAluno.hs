module Modules.MenuAluno where
import Modules.GerenciadorOpcoesAluno
import Modules.Controllers.GerenciadorOpcoesAlunoController
import System.Console.Pretty


exibirMenuAluno :: String -> IO()
exibirMenuAluno matricula = do
    putStrLn (color Blue . style Bold $ "===== Menu do aluno: " ++ matricula ++ " =====")
    listaDisciplinasTurmas <- Modules.GerenciadorOpcoesAluno.listarDisciplinasTurmas matricula
    putStrLn listaDisciplinasTurmas
    putStrLn (color Blue "Digite a disciplina que você deseja acessar ou ENTER para sair: ")
    disciplina <- getLine
    putStrLn (color Blue "\nDigite a turma que você deseja acessar ou ENTER para sair: ")
    turma <- getLine
    if (disciplina == "" && turma == "") then putStrLn " "
    else do
        turmaValida <- Modules.GerenciadorOpcoesAluno.turmaValida matricula disciplina turma
        if turmaValida then  do 
            Modules.Controllers.GerenciadorOpcoesAlunoController.menuTurmaAluno matricula disciplina turma
            exibirMenuAluno matricula
        else do 
            putStrLn (color Red "\nDisciplina e/ou turma inválida.")
            putStrLn " "
            exibirMenuAluno matricula
