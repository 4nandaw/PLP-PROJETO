module Modules.GerenciadorOpcoesAlunoController where
import Modules.GerenciadorOpcoesAluno
import Modules.GerenciadorOpcoesDisciplinaController

visualizarNotasController :: String -> String -> String -> IO()
visualizarNotasController matricula disciplina turma = do 
    situacao <- Modules.GerenciadorOpcoesAluno.visualizarNotas matricula disciplina turma
    putStrLn situacao


escolherOpcaoMenuTurmaAluno :: String -> String -> String -> String -> IO()
escolherOpcaoMenuTurmaAluno escolha matricula disciplina turma
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = visualizarNotasController matricula disciplina turma
        | (escolha == "2") = responderQuizController disciplina turma
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
    putStrLn "Digite [1] para ver suas notas"
    putStrLn "Digite [2] para responder um Quiz"
    escolherOpcaoAluno matricula disciplina turma

responderQuizController :: String -> String -> IO ()
responderQuizController disciplina codTurma = do
    putStrLn "Digite o titulo do Quiz que você quer respoder: "
    titulo <- getLine
    tituloValido <- Modules.GerenciadorOpcoesAluno.validarTituloQuiz disciplina codTurma titulo
    if tituloValido then do
        listaPerguntas <- Modules.GerenciadorOpcoesAluno.perguntasQuiz disciplina codTurma titulo
        responderPerguntasQuizController disciplina codTurma titulo listaPerguntas []
    else do
        putStrLn "Título de Quiz inválido"

responderPerguntasQuizController :: String -> String -> String -> [String] -> [Bool] -> IO ()
responderPerguntasQuizController disciplina codTurma titulo listaPerguntas listaRespostasAluno = do
    if listaPerguntas == [] then exibirRespostasCertasController disciplina codTurma titulo listaRespostasAluno
    else do
        let pergunta = Modules.GerenciadorOpcoesAluno.getHead listaPerguntas
        putStrLn pergunta
        putStrLn "Digite sua resposta, apenas S para verdadeiro e N para falso"
        respostaAluno <- getLine
        let respostaValida = Modules.GerenciadorOpcoesAluno.validarResposta respostaAluno
        if not respostaValida then do
            putStrLn "Digite apenas S para verdadeiro e N para falso"
            responderPerguntasQuizController disciplina codTurma titulo listaPerguntas listaRespostasAluno
        else do
            let respostaAlunoBool = Modules.GerenciadorOpcoesAluno.pegarRespostaAlunoBool respostaAluno
            let tailListaPerguntas = Modules.GerenciadorOpcoesAluno.getTail listaPerguntas
            responderPerguntasQuizController disciplina codTurma titulo tailListaPerguntas (listaRespostasAluno ++ [respostaAlunoBool])        

exibirRespostasCertasController :: String -> String -> String -> [Bool] -> IO ()
exibirRespostasCertasController disciplina codTurma titulo listaRespostasAluno = do
    stringFormatada <- Modules.GerenciadorOpcoesAluno.exibirRespostasCertas disciplina codTurma titulo listaRespostasAluno
    putStrLn stringFormatada

            


