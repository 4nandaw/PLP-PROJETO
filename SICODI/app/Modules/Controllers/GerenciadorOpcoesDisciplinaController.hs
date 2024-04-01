module Modules.Controllers.GerenciadorOpcoesDisciplinaController where
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
    putStrLn (color Magenta . style Bold $ "\n===== ADICIONANDO FALTA ===== \n")
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
    putStrLn (color Magenta "\nDigite a matrícula do aluno que deseja alocar as notas ou ENTER para sair ")
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn (color Green "\nRegistro de notas finalizado!")
    else do
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
        
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
        else do 
            putStrLn (color Red "\nAluno não existe. Tente novamente.")

        adicionarNotasTurmaController disciplina codTurma

salvarNotaController :: String -> String -> String -> String -> IO()
salvarNotaController disciplina codTurma matriculaAluno escolha = do
    putStrLn (color Magenta "\nDigite o valor da nota: ")
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota disciplina codTurma matriculaAluno escolha nota
    putStrLn notaSalva

menuNotas :: String -> String -> String -> IO()
menuNotas disciplina codTurma matriculaAluno = do
    putStrLn(color Magenta . style Bold $ "\n===== ADICIONANDO NOTAS DO ALUNO " ++ matriculaAluno ++ " =====")
    putStrLn " "
    putStrLn "Digite uma opção: "
    putStrLn "[0] para voltar"
    putStrLn "[1] para adicionar a 1º nota"
    putStrLn "[2] para adicionar a 2º nota"
    putStrLn "[3] para adicionar a 3º nota"
    putStrLn "[4] para ver a situação do aluno" 
    escolha <- getLine
    if (escolha == "0") then putStr ""
    else do
        if (escolha /= "0" && escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4") then do
            putStrLn (color Red "\nOpção inválida.")
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
    alunos <- Modules.GerenciadorOpcoesDisciplina.verAlunosChat disciplina codTurma
    putStrLn $ alunos
    putStrLn (color Red "AVISO: " ++ color White "se você deseja sair do chat, basta dar ENTER a qualquer momento da conversa. ")
    putStrLn (color Magenta "\nDigite a matrícula do aluno que deseja iniciar um chat: ")
    matriculaAluno <- getLine
    if matriculaAluno == "" then putStrLn " "
    else do
        chatValido <- Modules.GerenciadorOpcoesDisciplina.verificarPossivelChat disciplina codTurma matriculaAluno
        if (chatValido) then do
            putStrLn " "
            putStrLn (color Magenta . style Bold $ "Mensagens anteriores: ")
            putStrLn " "
            chat <- Modules.GerenciadorOpcoesDisciplina.acessarChat disciplina codTurma matriculaAluno
            putStrLn chat
            enviarMensagemController disciplina codTurma matriculaAluno
        else do
            putStrLn (color Red "\nAluno não está na turma.")
            putStrLn ""

enviarMensagemController :: String -> String -> String -> IO()
enviarMensagemController disciplina codTurma matriculaAluno = do
    msg <- getLine

    remetente <- lerNomeProfessor disciplina

    if msg /= "" then do 
        enviarMensagem disciplina codTurma remetente matriculaAluno msg
        enviarMensagemController disciplina codTurma matriculaAluno
    else putStrLn (color Magenta "========================")

menuTurmaEscolhida :: String -> String -> IO()
menuTurmaEscolhida disciplina codTurma = do
    putStrLn (color Magenta . style Bold $ "\nMENU " ++ (map toUpper codTurma) ++ " ===============")
    putStrLn (color Magenta "Escolha uma opção: ")
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver alunos da turma"
    putStrLn "[2] Adicionar notas e ver situação de um aluno"
    putStrLn "[3] Adicionar faltas"
    putStrLn "[4] Ver relatório da turma"
    putStrLn "[5] Ver avaliações"
    putStrLn "[6] Mural da Turma"
    putStrLn "[7] Chat"
    putStrLn "[8] Materiais Didáticos"
    putStrLn "[9] Quizzes da turma"
    putStrLn (color Magenta . style Bold $ "=================================")
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
        | (opcao == "8") = do
            menuMaterialDidatico disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | (opcao == "9") = do
            menuQuiz disciplina codTurma
            menuTurmaEscolhida disciplina codTurma
        | otherwise = do
            putStrLn (color Red "\nOpção inválida." )
            menuTurmaEscolhida disciplina codTurma

menuMural :: String -> String -> IO()
menuMural disciplina codTurma = do
    putStrLn (color Magenta . style Bold $ "\nMURAL DA TURMA ============================")
    putStrLn (color Magenta "Escolha uma opção: ")
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver Mural"
    putStrLn "[2] Deixar aviso no Mural"
    putStrLn (color Magenta . style Bold $ "===============================================")
    opcao <- getLine

    if opcao /= "" then do
        escolherOpcaoMenuMural opcao disciplina codTurma
    else do
        putStrLn (color Red "\nOpção inválida.")
        menuMural disciplina codTurma

escolherOpcaoMenuMural :: String -> String -> String -> IO()
escolherOpcaoMenuMural opcao disciplina codTurma
    | (opcao == "0") = putStr ""
    | (opcao == "1") = exibirMuralController disciplina codTurma
    | (opcao == "2") = do
        criarAvisoMuralController disciplina codTurma
        menuMural disciplina codTurma
    | otherwise = putStrLn (color Red "\nOpção inválida.")

criarAvisoMuralController :: String -> String -> IO ()
criarAvisoMuralController disciplina codTurma = do
    putStrLn (color Magenta "\nDigite o aviso para toda turma ou ENTER para sair: ")
    aviso <- getLine

    if null aviso then
        putStrLn (color Green "Saindo do Mural da Turma...")
    else do
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
    putStrLn (color Magenta . style Bold $ "\nRELATÓRIO DA TURMA =======================================\n")
    putStrLn mediaN
    putStrLn ""
    putStrLn mediaF
    putStrLn (color Magenta . style Bold $ "\n==========================================================")

exibirAvaliacoes :: String -> String -> IO()
exibirAvaliacoes disciplina codTurma = do
    media <- mediaAvaliacoes disciplina codTurma
    feedbacks <- verAvaliacoes disciplina codTurma
    putStrLn (color Magenta . style Bold $ "\nAVALIAÇÕES ====================================\n")
    putStrLn media
    putStrLn feedbacks
    putStrLn (color Magenta . style Bold $ "===============================================")

exibirMuralController :: String -> String -> IO()
exibirMuralController disciplina codTurma = do
    avisos <- Modules.GerenciadorOpcoesDisciplina.exibirAvisosMural disciplina codTurma
    putStrLn avisos

menuMaterialDidatico :: String -> String -> IO()
menuMaterialDidatico disciplina codTurma = do
    putStrLn (color Magenta . style Bold $ "\nMATERIAIS DIDÁTICOS ============================")
    putStrLn (color Magenta"Escolha uma opção: ")
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver Materiais Didáticos"
    putStrLn "[2] Adicionar novo Material Didático para turma"
    putStrLn (color Magenta . style Bold $ "===============================================")
    opcao <- getLine

    if opcao /= "" then do
        escolherOpcaoMaterialDidatico opcao disciplina codTurma
    else do
        putStrLn (color Red "Opção inválida.")
        menuMaterialDidatico disciplina codTurma

escolherOpcaoMaterialDidatico :: String -> String -> String -> IO()
escolherOpcaoMaterialDidatico opcao disciplina codTurma
    | (opcao == "0") = putStr ""
    | (opcao == "1") = exibirMaterialDidaticoController disciplina codTurma
    | (opcao == "2") = criarMaterialDidaticoController disciplina codTurma
    | otherwise = do 
        putStrLn (color Red"\nOpção inválida!")
        menuMaterialDidatico disciplina codTurma

exibirMaterialDidaticoController :: String -> String -> IO()
exibirMaterialDidaticoController disciplina codTurma = do
    materiais <- exibirMaterialDidatico disciplina codTurma
    putStrLn materiais

criarMaterialDidaticoController :: String -> String -> IO()
criarMaterialDidaticoController disciplina codTurma = do
    putStrLn (color Magenta "\nInsira o TÍTULO do Material Didático para toda turma ou ENTER para sair: ")
    titulo <- getLine

    if null titulo then
        putStrLn (color Green "Saindo de Materiais Didáticos...\n")
    else do
        putStrLn (color Magenta"\nInsira o CONTEÚDO do Material Didático para toda turma ou ENTER para sair: ")
        conteudo <- getLine

        if null conteudo then
            putStrLn (color Green "Saindo de Materiais Didáticos...\n")
        else do
            salvarMaterial <- Modules.GerenciadorOpcoesDisciplina.criarMaterialDidatico disciplina codTurma titulo conteudo
            putStrLn salvarMaterial
            
-- Função para exibir o menu principal
menuQuiz :: String -> String -> IO ()
menuQuiz disciplina codTurma = do
    putStrLn (color Magenta . style Bold $ "\n===== MENU QUIZ ======")
    putStrLn $ color Magenta "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Criar Quiz"
    putStrLn "[2] Adicionar pergunta a um Quiz"
    putStrLn (color Magenta . style Bold $"======================")
    opcao <- getLine
    escolherOpcaoQuiz disciplina codTurma opcao

escolherOpcaoQuiz :: String -> String -> String -> IO()
escolherOpcaoQuiz disciplina codTurma opcao
    | (opcao == "0") = putStrLn " "
    | (opcao == "1") = criarQuizController disciplina codTurma
    | (opcao == "2") = adicionarPerguntasQuizController disciplina codTurma
    | (otherwise) = do 
        putStrLn $ color Red "\nOpção inválida\n"
        menuQuiz disciplina codTurma
    
criarQuizController :: String -> String -> IO ()
criarQuizController disciplina codTurma = do
    putStrLn $ color Magenta "\nQual o título do Quiz?"
    titulo <- getLine
    if (titulo /= "") then do
        quizValido <- Modules.GerenciadorOpcoesDisciplina.criarQuiz disciplina codTurma titulo
        if quizValido then do
            putStrLn $ color Green "\nQuiz criado! Agora adicione as perguntas e as respostas!\n" 
            adicionarPerguntasRespostasController disciplina codTurma titulo
            else do
                putStrLn $ color Red "\nJá existe quiz com esse nome!"
    else putStrLn $ color Red "\nDigite um título válido, que não seja branco ou nulo!"

adicionarPerguntasQuizController :: String -> String -> IO()
adicionarPerguntasQuizController disciplina codTurma = do
    lista <- Modules.GerenciadorOpcoesDisciplina.listarQuizzes disciplina codTurma
    quizzesExistentes <- Modules.GerenciadorOpcoesDisciplina.verificarQuizzesExistentes disciplina codTurma
    if not quizzesExistentes then putStrLn lista
    else do 
        putStrLn $ color Magenta . style Bold $ "\n======== LISTA DE QUIZZES ========"
        putStrLn (color White lista)
        putStrLn $ color Magenta "\nQual o título do Quiz? "
        titulo <- getLine
        quizValido <- Modules.GerenciadorOpcoesDisciplina.quizExiste disciplina codTurma titulo
        if quizValido then do
            putStrLn ""
            adicionarPerguntasRespostasController disciplina codTurma titulo
        else putStrLn $ color Red "\nQuiz não existe."

adicionarPerguntasRespostasController :: String -> String -> String -> IO ()
adicionarPerguntasRespostasController disciplina codTurma titulo = do
    putStrLn (color Magenta . style Bold $ "============ NOVA PERGUNTA ============")
    putStrLn $ color Magenta "Digite a pergunta ou ENTER para sair: "
    pergunta <- getLine
    if pergunta == "" then putStrLn $ color Green "A adição de novas perguntas foi finalizada."
    else do
        putStrLn $ color Magenta "\nDigite a resposta (digite V para verdadeiro e F para falso): "
        resposta <- getLine
        let respostaValida = Modules.GerenciadorOpcoesDisciplina.validarResposta resposta
        if respostaValida then do
            putStrLn $ color Green "\nPergunta adicionada.\n"
            Modules.GerenciadorOpcoesDisciplina.adicionarPergunta disciplina codTurma titulo pergunta resposta 
            adicionarPerguntasRespostasController disciplina codTurma titulo
            else do
                putStrLn $ color Red $ "\nDigite apenas V para verdadeiro ou F para falso.\n"
                adicionarPerguntasRespostasController disciplina codTurma titulo