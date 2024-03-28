module Modules.MenuAluno where
import Modules.GerenciadorOpcoesAluno
import Modules.GerenciadorOpcoesAlunoController
import System.Console.Pretty


exibirMenuAluno :: String -> IO()
exibirMenuAluno matricula = do
    putStrLn (color Blue . style Bold $ "===== Menu do aluno: " ++ matricula ++ " =====")
    putStrLn "Digite ENTER para voltar"
    putStrLn " "
    listaDisciplinasTurmas <- Modules.GerenciadorOpcoesAluno.listarDisciplinasTurmas matricula
    putStrLn listaDisciplinasTurmas
    putStrLn (color Blue "Digite a disciplina que você quer entrar: ")
    disciplina <- getLine
    putStrLn (color Blue "Digite a turma: ")
    turma <- getLine
    if (disciplina == "" && turma == "") then putStrLn " "
    else do
        turmaValida <- Modules.GerenciadorOpcoesAluno.turmaValida matricula disciplina turma
        if turmaValida then  do 
            Modules.GerenciadorOpcoesAlunoController.menuTurmaAluno matricula disciplina turma
            exibirMenuAluno matricula
        else do 
            putStrLn (color Red "Disciplina e/ou turma inválida")
            putStrLn " "
            exibirMenuAluno matricula
