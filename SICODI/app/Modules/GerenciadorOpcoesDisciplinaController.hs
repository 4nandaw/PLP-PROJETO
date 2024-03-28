module Modules.GerenciadorOpcoesDisciplinaController where
import Modules.GerenciadorOpcoesDisciplina
import Modules.GerenciadorTurmas
import Modules.Chat
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.Console.Pretty
import Data.Char (toUpper)


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
        let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json"
        alunoValido <- verificarAluno diretorio
        if alunoValido then do
            Modules.GerenciadorOpcoesDisciplina.adicionarFalta disciplina codTurma matriculaAluno
            menuFaltas disciplina
        else do
            putStrLn (color Red "Aluno inválido.")
            menuFaltas disciplina

-- Função para verificar se o aluno informado pertence à turma
verificarAluno :: String -> IO Bool
verificarAluno diretorio = do
    alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma diretorio
    return alunoValido

adicionarNotasTurmaController :: String -> IO()
adicionarNotasTurmaController diretorio = do
    putStrLn (color Magenta "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair ")
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn (color Green "Registro de notas finalizado!")
    else do
        let diretorioAluno = diretorio ++ matriculaAluno ++ ".json"
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma diretorioAluno
        if (alunoValido) then do 
            menuNotas diretorioAluno matriculaAluno
            adicionarNotasTurmaController diretorio
        else do 
            putStrLn (color Red "Aluno não existe")
            adicionarNotasTurmaController diretorio

salvarNotaController :: String -> String -> IO()
salvarNotaController diretorio escolha = do
    putStrLn (color Magenta "Digite o valor da nota: ")
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota diretorio escolha nota
    putStrLn notaSalva

menuNotas :: String -> String -> IO()
menuNotas diretorio matriculaAluno = do
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
            menuNotas diretorio matriculaAluno
        else do
            if (escolha == "4") then do 
                situacao <- Modules.GerenciadorOpcoesDisciplina.situacaoAluno diretorio matriculaAluno
                putStrLn situacao
                menuNotas diretorio matriculaAluno

            else do 
                salvarNotaController diretorio escolha
                menuNotas diretorio matriculaAluno

chatController :: String -> IO()
chatController disciplina = do
    putStrLn "DIGITE ENTER NA TURMA E ALUNO CASO DESEJE SAIR"
    putStrLn ""
    --Possível lista de turmas da disciplina // ver depois se necessário fz
    putStrLn "Digite a turma que deseja entrar e iniciar um chat com o aluno"
    codTurma <- getLine
    --Possível lista de alunos que estão matriculados na turma // ver depois se necessário fz
    putStrLn "Digite a matrícula do aluno que deseja iniciar um chat"
    matriculaAluno <- getLine
    if (codTurma == "" && matriculaAluno == "") then putStrLn " "
    else do
        chatValido <- Modules.GerenciadorOpcoesDisciplina.verificarPossivelChat disciplina codTurma matriculaAluno
        if (chatValido) then do
            putStrLn " "
            putStrLn "Mensagens anteriores: "
            putStrLn " "
            chat <- Modules.GerenciadorOpcoesDisciplina.acessarChat disciplina codTurma matriculaAluno
            putStrLn chat
        else do
            putStrLn "Turma inválida ou aluno não está na turma"
            putStrLn " "

        enviarMensagemController disciplina codTurma matriculaAluno

enviarMensagemController :: String -> String -> String -> IO()
enviarMensagemController disciplina codTurma matriculaAluno = do
    putStrLn ":"
    msg <- getLine

    remetente <- lerNomeProfessor disciplina

    if msg /= "" then do 
        enviarMensagem disciplina codTurma remetente matriculaAluno msg
        enviarMensagemController disciplina codTurma matriculaAluno
    else putStrLn "========================"


menuTurmaEscolhida :: String -> String -> IO()
menuTurmaEscolhida diretorio codigo = do
    putStrLn $ "MENU " ++ (map toUpper codigo) ++ " ==============="
    putStrLn "Escolha uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver alunos da turma"
    putStrLn "[2] Adicionar notas"
    putStrLn "[3] Adicionar faltas"
    putStrLn "[4] Ver relatório da turma"
    putStrLn "[5] Ver avaliações"
    putStrLn "[6] Mural da Turma"
    putStrLn "[7] Chat"
    putStrLn "==============================================="
    opcao <- getLine

    escolherOpcaoMenuMinhasTurmas opcao diretorio codigo

escolherOpcaoMenuMinhasTurmas :: String -> String -> String -> IO()
escolherOpcaoMenuMinhasTurmas opcao diretorio codigo
        | (opcao == "0") = putStr ""
        | (opcao == "1") = do 
            responseAlunos (diretorio ++ codigo ++ "/alunos/")
            menuTurmaEscolhida diretorio codigo
        | (opcao == "2") = do
            adicionarNotasTurmaController (diretorio ++ codigo ++ "/alunos/")
            menuTurmaEscolhida diretorio codigo
        | (opcao == "4") = do
            exibirRelatorio (diretorio ++ codigo ++ "/alunos/")
            menuTurmaEscolhida diretorio codigo
        | (opcao == "5") = do
            exibirAvaliacoes (diretorio ++ codigo ++ "/avaliacoes/")
            menuTurmaEscolhida diretorio codigo
        | (opcao == "6") = do
            menuMural (diretorio ++ codigo ++ "/mural/") 
            menuTurmaEscolhida diretorio codigo
        | otherwise = do
            putStrLn "Opção Inválida!" 
            menuTurmaEscolhida diretorio codigo

menuMural :: String -> IO()
menuMural diretorio = do
    putStrLn "Escolha uma opção: "
    putStrLn "[1] Ver Mural"
    putStrLn "[2] Deixar aviso no Mural"
    putStrLn "==============================================="
    opcao <- getLine

    if opcao /= "" then do
        escolherOpcaoMenuMural opcao diretorio
    else putStrLn "Opção inválida!"

escolherOpcaoMenuMural :: String -> String -> IO()
escolherOpcaoMenuMural opcao diretorio
    | (opcao == "0") = putStr ""
    | (opcao == "1") = putStrLn "ver mural"
    | (opcao == "2") = criarAvisoTurmaController diretorio
    | otherwise = putStrLn "Opção inválida!"

criarAvisoTurmaController :: String -> IO ()
criarAvisoTurmaController diretorio = do
    putStrLn "Digite o aviso para toda turma: "
    aviso <- getLine
    salvarAviso <- Modules.GerenciadorOpcoesDisciplina.criarAvisoTurma diretorio aviso
    putStrLn salvarAviso

responseAlunos :: String -> IO()
responseAlunos diretorio = do
    alunos <- verAlunos diretorio
    putStrLn alunos    

exibirRelatorio :: String -> IO()
exibirRelatorio diretorio = do
    mediaF <- mediaFaltas diretorio
    mediaN <- mediaNotas diretorio
    putStrLn "\nRELATÓRIO DA TURMA ============================\n"
    putStrLn mediaN
    putStrLn ""
    putStrLn mediaF
    putStrLn "\n==============================================="

exibirAvaliacoes :: String -> IO()
exibirAvaliacoes diretorio = do
    media <- mediaAvaliacoes diretorio
    feedbacks <- verAvaliacoes diretorio
    putStrLn "\nAVALIAÇÕES ====================================\n"
    putStrLn media
    putStrLn feedbacks
    putStrLn "==============================================="
