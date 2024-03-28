module Modules.GerenciadorOpcoesDisciplinaController where
import Modules.GerenciadorOpcoesDisciplina
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.Console.Pretty

menuDeDisciplina :: String -> IO()
menuDeDisciplina disciplina = do
    putStrLn (color Magenta . style Bold $  "MENU DE DISCIPLINA ==================")
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Adicionar notas"
    putStrLn "[2] Adicionar falta a aluno(a)"
    putStrLn (color Magenta . style Bold $ "=====================================")
    escolherOpcaoDisciplina disciplina

escolherOpcaoDisciplina :: String -> IO()
escolherOpcaoDisciplina disciplina = do
    escolha <- getLine
    escolherOpcaoMenuDisciplina escolha disciplina
    if (escolha /= "0") then menuDeDisciplina disciplina
    else putStrLn " "

escolherOpcaoMenuDisciplina :: String -> String -> IO()
escolherOpcaoMenuDisciplina escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = solicitarEAlocarNotasController disciplina
        | (escolha == "2") = menuFaltas disciplina
        | otherwise = putStrLn (color Red "Opção Inválida.")

-- Função principal que inicia o menu para adicionar faltas
menuFaltas :: String -> IO ()
menuFaltas disciplina = do
    putStrLn (color Magenta . style Bold $ "===== ADICIONANDO FALTA ===== ")
    putStrLn " "
    putStrLn (color Magenta . style Bold $ "Informe o código da turma ou ENTER para sair: ")
    codTurma <- getLine
    if codTurma == "" then
        putStrLn (color Green "Registro de notas finalizado!")
    else do
        turmaValida <- verificarTurma disciplina codTurma
        if turmaValida then
            adicionarFaltas disciplina codTurma
        else do
            putStrLn (color Red "Turma inválida.")
            menuFaltas disciplina

-- Função para verificar se a turma informada é válida
verificarTurma :: String -> String -> IO Bool
verificarTurma disciplina codTurma = do
    turmaValida <- Modules.GerenciadorOpcoesDisciplina.verificadorArquivoTurma disciplina codTurma
    return turmaValida

-- Função para adicionar faltas para um aluno específico
adicionarFaltas :: String -> String -> IO ()
adicionarFaltas disciplina codTurma = do
    putStrLn (color Magenta "Digite a matrícula do aluno que deseja alocar 1 falta ou ENTER para sair: ")
    matriculaAluno <- getLine
    if matriculaAluno == "" then
        putStrLn (color Green "Registro de notas finalizado!")
    else do
        alunoValido <- verificarAluno disciplina codTurma matriculaAluno
        if alunoValido then do
            Modules.GerenciadorOpcoesDisciplina.adicionarFalta disciplina codTurma matriculaAluno
            menuFaltas disciplina
        else do
            putStrLn (color Red "Aluno inválido.")
            menuFaltas disciplina

-- Função para verificar se o aluno informado pertence à turma
verificarAluno :: String -> String -> String -> IO Bool
verificarAluno disciplina codTurma matriculaAluno = do
    alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
    return alunoValido

solicitarEAlocarNotasController :: String -> IO()
solicitarEAlocarNotasController disciplina = do 
    putStrLn (color Magenta . style Bold $  "===== ADICIONANDO NOTAS ===== ")
    putStrLn " "
    putStrLn (color Magenta "Informe o código da turma: ")
    codTurma <- getLine
    turmaValida <- verificadorArquivoTurma disciplina codTurma
    if (turmaValida) then adicionarNotasTurmaController disciplina codTurma
    else putStrLn (color Red "Turma não existe")

adicionarNotasTurmaController :: String -> String -> IO()
adicionarNotasTurmaController disciplina codTurma = do
    putStrLn (color Magenta "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair ")
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn (color Green "Registro de notas finalizado!")
    else do
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
            adicionarNotasTurmaController disciplina codTurma
        else do 
            putStrLn (color Red "Aluno não existe")
            adicionarNotasTurmaController disciplina codTurma

salvarNotaController :: String -> String -> String -> String -> IO()
salvarNotaController disciplina codTurma matriculaAluno escolha = do
    putStrLn (color Magenta "Digite o valor da nota: ")
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota  disciplina codTurma matriculaAluno escolha nota
    putStrLn (notaSalva)

menuNotas :: String -> String -> String -> IO()
menuNotas disciplina codTurma matriculaAluno = do
    putStrLn(color Magenta . style Bold $ "===== ADICIONANDO NOTAS DO ALUNO " ++ matriculaAluno ++ " =====")
    putStrLn " "
    putStrLn "Digite uma opção: "
    putStrLn "[0] para voltar"
    putStrLn "[1] para adicionar a 1º nota"
    putStrLn "[2] para adicionar a 2º nota"
    putStrLn "[3] para adicionar a 3º nota"
    putStrLn "[4] para ver a situação do aluno" 
    escolha <- getLine
    if (escolha == "0") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4") then do
            putStrLn (color Red "Opção Inválida")
            menuNotas disciplina codTurma matriculaAluno
        else do
            if (escolha == "4") then do 
                situacao <- Modules.GerenciadorOpcoesDisciplina.situacaoAluno disciplina codTurma matriculaAluno
                putStrLn situacao
                menuNotas disciplina codTurma matriculaAluno

            else do 
                salvarNotaController disciplina codTurma matriculaAluno escolha
                menuNotas disciplina codTurma matriculaAluno
