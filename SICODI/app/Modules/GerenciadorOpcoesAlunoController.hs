module Modules.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno



visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao


escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | otherwise = putStrLn "Opção Inválida!!"


escolherOpcaoAluno :: String -> String -> String -> IO()
escolherOpcaoAluno matricula disciplina turma = do 
    escolha <- getLine
    escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
    if (escolha /= "0") then menuTurmaAluno matricula disciplina turma 
    else putStrLn " "

menuTurmaAluno :: String -> String -> String -> IO()
menuTurmaAluno matricula disciplina turma = do
    putStrLn ("===== Menu do aluno " ++ matricula ++ ", na disciplina " ++ disciplina ++ " e turma " ++ turma ++ "! =====")
    putStrLn "Digite [0] para voltar"
    putStrLn "Digite [1] para ver sua situação atual (notas, faltas e média na turma)"
    escolherOpcaoAluno matricula disciplina turma