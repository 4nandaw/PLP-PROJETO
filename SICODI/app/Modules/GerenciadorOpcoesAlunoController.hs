module Modules.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno

menuTurmaAluno :: String -> String -> String -> IO()
menuTurmaAluno matricula disciplina turma = do
    putStrLn ("===== Menu do aluno " ++ matricula ++ ", na disciplina " ++ disciplina ++ " e turma " ++ turma ++ "! =====\n")
    putStrLn "Digite uma opção:"
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver notas"
    putStrLn "[2] Avaliar professor(a)"
    putStrLn "=============================================================="
    escolherOpcaoAluno matricula disciplina turma

escolherOpcaoAluno :: String -> String -> String -> IO()
escolherOpcaoAluno matricula disciplina turma = do 
    escolha <- getLine
    escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
    if (escolha /= "0") then menuTurmaAluno matricula disciplina turma 
    else putStrLn " "

escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | (escolha == "2") = menuAvaliacoes matricula disciplina turma
        | otherwise = putStrLn "Opção Inválida!"

visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao

menuAvaliacoes :: String -> String -> String -> IO()
menuAvaliacoes matricula disciplina turma = do
    putStrLn "\nAVALIAÇÃO DE DESEMPENHO DO PROFESSOR ====="
    putStrLn "Digite uma opção: "       
    putStrLn "[1] Péssimo"
    putStrLn "[2] Ruim"
    putStrLn "[3] Ok"
    putStrLn "[4] Bom"
    putStrLn "[5] Excelente"
    putStrLn "=========================================="
    escolha <- getLine
    let nota = (read escolha :: Int)

    if (escolha == "0") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4" && escolha /= "5") then do
            putStrLn "Opção Inválida"
        else
            escolherOpcaoAvaliacao matricula disciplina turma nota

escolherOpcaoAvaliacao :: String -> String -> String -> Int -> IO()
escolherOpcaoAvaliacao matricula disciplina turma nota = do
    putStrLn "Comentário: "
    comentario <- getLine
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/avaliacoes/"
    avaliacaoSave <- Modules.GerenciadorOpcoesAluno.salvarAvaliacao diretorio nota comentario matricula
    putStrLn avaliacaoSave