module Modules.Controllers.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno
import Modules.GerenciadorOpcoesDisciplina
import Modules.Controllers.GerenciadorOpcoesDisciplinaController
import System.Console.Pretty

import Modules.Chat


chatAlunoController :: String -> String -> String -> IO()
chatAlunoController matricula disciplina turma = do
    putStrLn ""
    putStrLn (color Red "AVISO: " ++ color White "se você deseja sair do chat, basta dar ENTER a qualquer momento da conversa.\n")
    putStrLn (color Blue . style Bold $ "Mensagens anteriores: ")
    chat <- Modules.GerenciadorOpcoesAluno.acessarChatAluno matricula disciplina turma
    putStrLn chat

    enviarMensagemAlunoController disciplina turma matricula


enviarMensagemAlunoController :: String -> String -> String -> IO()
enviarMensagemAlunoController disciplina codTurma matriculaAluno = do
    msg <- getLine


    remetente <- lerNomeAluno matriculaAluno

    if msg /= "" then do 
        enviarMensagem disciplina codTurma remetente matriculaAluno msg
        enviarMensagemAlunoController disciplina codTurma matriculaAluno
    else putStrLn (color Blue . style Bold $ "====================")

menuTurmaAluno :: String -> String -> String -> IO()
menuTurmaAluno matricula disciplina turma = do
    let msg = "\n===== Menu do aluno " ++ matricula ++ ", na disciplina " ++ disciplina ++ " e turma " ++ turma ++ "! ====="
    putStrLn (color Blue . style Bold $ msg)
    putStrLn (color Blue "Digite uma opção:")
    putStrLn "[0] Voltar"
    putStrLn "[1] Ver notas"
    putStrLn "[2] Ver Mural"
    putStrLn "[3] Chat"
    putStrLn "[4] Avaliar professor(a)"
    putStrLn "[5] Materiais Didáticos"
    putStrLn "[6] Responder quiz"
    putStrLn (color Blue . style Bold $ "==============================================================")
    escolherOpcaoAluno matricula disciplina turma

escolherOpcaoAluno :: String -> String -> String -> IO()
escolherOpcaoAluno matricula disciplina turma = do 
    escolha <- getLine
    escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
    if (escolha /= "0") then menuTurmaAluno matricula disciplina turma 
    else putStrLn " "

escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn ""
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | (escolha == "2") = exibirMuralAlunoController disciplina turma
        | (escolha == "3") = chatAlunoController matricula disciplina turma
        | (escolha == "4") = menuAvaliacoes matricula disciplina turma
        | (escolha == "5") = Modules.Controllers.GerenciadorOpcoesDisciplinaController.exibirMaterialDidaticoController disciplina turma
        | (escolha == "6") = escolherQuiz disciplina turma
        | otherwise = putStrLn (color Red "\nOpção inválida.")

visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao

exibirMuralAlunoController :: String -> String -> IO()
exibirMuralAlunoController disciplina codTurma = do
    avisos <- Modules.GerenciadorOpcoesDisciplina.exibirAvisosMural disciplina codTurma
    putStrLn avisos

menuAvaliacoes :: String -> String -> String -> IO()
menuAvaliacoes matricula disciplina turma = do
    putStrLn (color Blue . style Bold $ "\nAVALIAÇÃO DE DESEMPENHO DO PROFESSOR =====")
    putStrLn (color Blue "Digite uma opção ou ENTER para sair: ")
    putStrLn ("[1] Péssimo")
    putStrLn ("[2] Ruim")
    putStrLn ("[3] Ok")
    putStrLn ("[4] Bom")
    putStrLn ("[5] Excelente")
    putStrLn (color Blue . style Bold $  "==========================================")
    escolha <- getLine
    
    let nota = (read escolha :: Int)

    if (escolha == "") then putStrLn " "
    else do
        if (escolha /= "1" && escolha /= "2" && escolha /= "3" && escolha /= "4" && escolha /= "5") then do
            putStrLn (color Red "\nOpção inválida.")
        else
            escolherOpcaoAvaliacao matricula disciplina turma nota

escolherOpcaoAvaliacao :: String -> String -> String -> Int -> IO()
escolherOpcaoAvaliacao matricula disciplina turma nota = do
    putStrLn (color Blue "\nComentário: ")
    comentario <- getLine
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ turma ++ "/avaliacoes/"
    avaliacaoSave <- Modules.GerenciadorOpcoesAluno.salvarAvaliacao diretorio nota comentario matricula
    putStrLn avaliacaoSave
    

escolherQuiz :: String -> String -> IO()
escolherQuiz disciplina codTurma = do
    lista <- Modules.GerenciadorOpcoesDisciplina.listarQuizzes disciplina codTurma
    quizzesExistentes <- Modules.GerenciadorOpcoesDisciplina.verificarQuizzesExistentes disciplina codTurma
    if not quizzesExistentes then putStrLn lista
    else do 
        putStrLn $ color Blue . style Bold $ "\n======== LISTA DE QUIZZES ========"
        putStrLn (color White lista)
        putStrLn (color Blue . style Bold $ "======= ESCOLHA QUAL QUIZ VOCÊ QUER RESPONDER =======")
        --Lista de quizzes
        putStrLn $ color Red "Atenção: " ++ (color White "Ao entrar no quiz, ele só irá fechar após responder todas as perguntas!")
        putStrLn $ color Blue "\nDigite o título do quiz: "
        titulo <- getLine
        tituloValido <- Modules.GerenciadorOpcoesAluno.validarTituloQuiz disciplina codTurma titulo
        if tituloValido then do
            listaPerguntas <- Modules.GerenciadorOpcoesAluno.perguntasQuiz disciplina codTurma titulo
            responderPerguntasQuizController disciplina codTurma titulo listaPerguntas []
        else putStrLn $ color Red "\nTítulo de quiz inválido"

responderPerguntasQuizController :: String -> String -> String -> [String] -> [Bool] -> IO ()
responderPerguntasQuizController disciplina codTurma titulo listaPerguntas listaRespostasAluno = do
    if listaPerguntas == [] then exibirRespostasCertasController disciplina codTurma titulo listaRespostasAluno
    else do
        putStrLn $ color Blue . style Bold $ "\n======== RESPONDA A PERGUNTA ========\n"
        let pergunta = Modules.GerenciadorOpcoesAluno.getHead listaPerguntas
        putStrLn $ color Blue pergunta
        let msg = (color White "Digite sua resposta, apenas") ++ (color Blue " V") ++ (color White " para verdadeiro e") ++ (color Blue " F") ++ (color White " para falso: ")
        putStrLn msg
        respostaAluno <- getLine
        let respostaValida = Modules.GerenciadorOpcoesAluno.validarResposta respostaAluno
        if not respostaValida then do
            putStrLn $ color Red "\nDigite apenas V para verdadeiro e F para falso."
            responderPerguntasQuizController disciplina codTurma titulo listaPerguntas listaRespostasAluno
        else do
            let respostaAlunoBool = Modules.GerenciadorOpcoesAluno.pegarRespostaAlunoBool respostaAluno
            let tailListaPerguntas = Modules.GerenciadorOpcoesAluno.getTail listaPerguntas
            responderPerguntasQuizController disciplina codTurma titulo tailListaPerguntas (listaRespostasAluno ++ [respostaAlunoBool])        

exibirRespostasCertasController :: String -> String -> String -> [Bool] -> IO ()
exibirRespostasCertasController disciplina codTurma titulo listaRespostasAluno = do
    putStrLn $ color Blue . style Bold $ "\n======== RESPOSTAS ========"
    stringFormatada <- Modules.GerenciadorOpcoesAluno.exibirRespostasCertas disciplina codTurma titulo listaRespostasAluno
    putStrLn stringFormatada

            
