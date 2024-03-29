module Modules.GerenciadorOpcoesDisciplinaController where
import Modules.GerenciadorOpcoesDisciplina
import Modules.GerenciadorTurmas
import Modules.Chat
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.Console.Pretty
import Data.Char (toUpper)

-- Função para verificar se a turma informada é válida
verificarTurma :: String -> String -> IO Bool
verificarTurma disciplina codTurma = do
    turmaValida <- Modules.GerenciadorOpcoesDisciplina.verificadorArquivoTurma disciplina codTurma
    return turmaValida

-- Função para adicionar faltas para um aluno específico
adicionarFaltas :: String -> String -> IO()
adicionarFaltas disciplina codTurma = do
    putStrLn (color Magenta . style Bold $ "===== ADICIONANDO FALTA ===== \n")
    putStrLn (color Magenta "Digite a matrícula do aluno que deseja alocar 1 falta ou ENTER para sair: ")
    matriculaAluno <- getLine

    if matriculaAluno == "" then
        putStrLn (color Green "Registro de notas finalizado!")
    else do
        alunoValido <- verificarAlunoTurma disciplina codTurma matriculaAluno
        
        if alunoValido then do
            Modules.GerenciadorOpcoesDisciplina.adicionarFalta disciplina codTurma matriculaAluno
        else return (color Red "Aluno inválido.")

        adicionarFaltas disciplina codTurma

adicionarNotasTurmaController :: String -> String -> IO()
adicionarNotasTurmaController disciplina codTurma = do
    putStrLn (color Magenta "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair ")
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn (color Green "Registro de notas finalizado!")
    else do
        -- let diretorioAluno = diretorio ++ matriculaAluno ++ ".json"
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
        
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
        else do 
            putStrLn (color Red "Aluno não existe")

        adicionarNotasTurmaController disciplina codTurma

salvarNotaController :: String -> String -> String -> String -> IO()
salvarNotaController disciplina codTurma matriculaAluno escolha = do
    putStrLn (color Magenta "Digite o valor da nota: ")
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota disciplina codTurma matriculaAluno escolha nota
    putStrLn notaSalva

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

chatController :: String -> String -> IO()
chatController disciplina codTurma = do
    putStrLn "DIGITE ENTER NO ALUNO CASO DESEJE SAIR"
    putStrLn ""
    --Possível lista de alunos que estão matriculados na turma // ver depois se necessário fz
    putStrLn "Digite a matrícula do aluno que deseja iniciar um chat"
    matriculaAluno <- getLine
    if matriculaAluno == "" then putStrLn " "
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
menuTurmaEscolhida disciplina codTurma = do
    putStrLn $ "MENU " ++ (map toUpper codTurma) ++ " ==============="
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

    escolherOpcaoMenuMinhasTurmas opcao disciplina codTurma

escolherOpcaoMenuMinhasTurmas :: String -> String -> String -> IO()
escolherOpcaoMenuMinhasTurmas opcao disciplina codTurma
        | (opcao == "0") = putStr ""
        | (opcao == "1") = do 
            responseAlunos disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "2") = do
            adicionarNotasTurmaController disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "3") = do
            adicionarFaltas disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "4") = do
            exibirRelatorio disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "5") = do
            exibirAvaliacoes disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "6") = do
            menuMural disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "7") = do
            chatController disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | otherwise = do
            putStrLn "Opção Inválida!" 
            menuTurmaEscolhida disciplina codTurma

menuMural :: String -> String -> IO()
menuMural disciplina codTurma = do
    putStrLn "Escolha uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver Mural"
    putStrLn "[2] Deixar aviso no Mural"
    putStrLn "==============================================="
    opcao <- getLine

    if opcao /= "" then do
        escolherOpcaoMenuMural opcao disciplina codTurma
    else putStrLn "Opção inválida!"

escolherOpcaoMenuMural :: String -> String -> String -> IO()
escolherOpcaoMenuMural opcao disciplina codTurma
    | (opcao == "0") = putStr ""
    | (opcao == "1") = exibirMuralController disciplina codTurma
    | (opcao == "2") = do
        criarAvisoMuralController disciplina codTurma
        menuMural disciplina codTurma
    | otherwise = putStrLn "Opção inválida!"

criarAvisoMuralController :: String -> String -> IO ()
criarAvisoMuralController disciplina codTurma = do
    putStrLn "Digite o aviso para toda turma: "
    aviso <- getLine
    salvarAviso <- Modules.GerenciadorOpcoesDisciplina.criarAvisoMural disciplina codTurma aviso
    putStrLn salvarAviso

responseAlunos :: String -> String -> IO()
responseAlunos disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/"

    alunos <- verAlunos disciplina codTurma
    putStrLn alunos

exibirRelatorio :: String -> String -> IO()
exibirRelatorio disciplina codTurma = do
    mediaF <- mediaFaltas disciplina codTurma
    mediaN <- mediaNotas disciplina codTurma
    putStrLn "\nRELATÓRIO DA TURMA ============================\n"
    putStrLn mediaN
    putStrLn ""
    putStrLn mediaF
    putStrLn "\n==============================================="

exibirAvaliacoes :: String -> String -> IO()
exibirAvaliacoes disciplina codTurma = do
    media <- mediaAvaliacoes disciplina codTurma
    feedbacks <- verAvaliacoes disciplina codTurma
    putStrLn "\nAVALIAÇÕES ====================================\n"
    putStrLn media
    putStrLn feedbacks
    putStrLn "==============================================="

exibirMuralController :: String -> String -> IO()
exibirMuralController disciplina codTurma = do
    avisos <- Modules.GerenciadorOpcoesDisciplina.exibirAvisosMural disciplina codTurma
    putStrLn avisos
