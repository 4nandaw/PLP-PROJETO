module Modules.GerenciadorOpcoesDisciplinaController where
import Modules.GerenciadorOpcoesDisciplina


menuNotas :: String -> String -> String -> IO()
menuNotas disciplina codTurma matriculaAluno = do
    putStrLn("===== ADICIONANDO NOTAS DO ALUNO " ++ matriculaAluno ++ " =====")
    putStrLn " "
    putStrLn "Digite qual nota você quer adicionar: "
    putStrLn "[0] para voltar"
    putStrLn "[1] para adicionar a 1º nota"
    putStrLn "[2] para adicionar a 2º nota"
    putStrLn "[3] para adicionar a 3º nota"
    putStrLn "[4] para ver a situação do aluno" 
    escolha <- getLine
    if (escolha == "0") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4") then do
            putStrLn "Opção Inválida"
            menuNotas disciplina codTurma matriculaAluno
        else do
            if (escolha == "4") then do 
                situacao <- Modules.GerenciadorOpcoesDisciplina.situacaoAluno disciplina codTurma matriculaAluno
                putStrLn situacao
                menuNotas disciplina codTurma matriculaAluno

            else do 
                salvarNotaController disciplina codTurma matriculaAluno escolha
                menuNotas disciplina codTurma matriculaAluno


salvarNotaController :: String -> String -> String -> String -> IO()
salvarNotaController disciplina codTurma matriculaAluno escolha = do
    putStrLn "Digite o valor da nota: "
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota  disciplina codTurma matriculaAluno escolha nota
    putStrLn (notaSalva)

adicionarNotasTurmaController :: String -> String -> IO()
adicionarNotasTurmaController disciplina codTurma = do
    putStrLn "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair "
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn "Registro de notas finalizado!"
    else do
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.adicionarNotasTurma disciplina codTurma matriculaAluno
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
            adicionarNotasTurmaController disciplina codTurma
        else do 
            putStrLn "Aluno não existe" 
            adicionarNotasTurmaController disciplina codTurma

solicitarEAlocarNotasController :: String -> IO()
solicitarEAlocarNotasController disciplina = do 
    putStrLn "===== ADICIONANDO NOTAS ===== "
    putStrLn " "
    putStrLn "Informe o código da turma: "
    codTurma <- getLine
    turmaValida <- solicitarEAlocarNotas disciplina codTurma
    if (turmaValida) then adicionarNotasTurmaController disciplina codTurma
    else putStrLn "Turma não existe"

escolherOpcaoMenuDisciplina :: String -> String -> IO()
escolherOpcaoMenuDisciplina escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = solicitarEAlocarNotasController disciplina
        | otherwise = putStrLn "Opção Inválida!!"

escolherOpcaoDisciplina :: String -> IO()
escolherOpcaoDisciplina disciplina = do
    escolha <- getLine
    escolherOpcaoMenuDisciplina escolha disciplina
    if (escolha /= "0") then menuDeDisciplina disciplina
    else putStrLn " "

menuDeDisciplina :: String -> IO()
menuDeDisciplina disciplina = do
    putStrLn "MENU DE DISCIPLINA ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Adicionar notas"
    escolherOpcaoDisciplina disciplina



