module Modules.GerenciadorOpcoesDisciplinaController where
import Modules.GerenciadorOpcoesDisciplina
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)

menuDeDisciplina :: String -> IO()
menuDeDisciplina disciplina = do
    putStrLn "MENU DE DISCIPLINA ====="
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Adicionar notas"
    putStrLn "[2] Adicionar falta a aluno(a)"
    putStrLn "[3] Adicionar Quiz"
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
        | (escolha == "3") = menuDeQuiz disciplina
        | otherwise = putStrLn "Opção Inválida."

-- Função principal que inicia o menu para adicionar faltas
menuFaltas :: String -> IO ()
menuFaltas disciplina = do
    putStrLn "===== ADICIONANDO FALTA ===== "
    putStrLn " "
    putStrLn "Informe o código da turma ou ENTER para sair: "
    codTurma <- getLine
    if codTurma == "" then
        putStrLn "Registro de notas finalizado!"
    else do
        turmaValida <- verificarTurma disciplina codTurma
        if turmaValida then
            adicionarFaltas disciplina codTurma
        else do
            putStrLn "Turma inválida."
            menuFaltas disciplina

-- Função para verificar se a turma informada é válida
verificarTurma :: String -> String -> IO Bool
verificarTurma disciplina codTurma = do
    turmaValida <- Modules.GerenciadorOpcoesDisciplina.verificadorArquivoTurma disciplina codTurma
    return turmaValida

-- Função para adicionar faltas para um aluno específico
adicionarFaltas :: String -> String -> IO ()
adicionarFaltas disciplina codTurma = do
    putStrLn "Digite a matrícula do aluno que deseja alocar 1 falta ou ENTER para sair: "
    matriculaAluno <- getLine
    if matriculaAluno == "" then
        putStrLn "Registro de notas finalizado!"
    else do
        alunoValido <- verificarAluno disciplina codTurma matriculaAluno
        if alunoValido then do
            Modules.GerenciadorOpcoesDisciplina.adicionarFalta disciplina codTurma matriculaAluno
            menuFaltas disciplina
        else do
            putStrLn "Aluno inválido."
            menuFaltas disciplina

-- Função para verificar se o aluno informado pertence à turma
verificarAluno :: String -> String -> String -> IO Bool
verificarAluno disciplina codTurma matriculaAluno = do
    alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
    return alunoValido


solicitarEAlocarNotasController :: String -> IO()
solicitarEAlocarNotasController disciplina = do 
    putStrLn "===== ADICIONANDO NOTAS ===== "
    putStrLn " "
    putStrLn "Informe o código da turma: "
    codTurma <- getLine
    turmaValida <- verificadorArquivoTurma disciplina codTurma
    if (turmaValida) then adicionarNotasTurmaController disciplina codTurma
    else putStrLn "Turma não existe"

adicionarNotasTurmaController :: String -> String -> IO()
adicionarNotasTurmaController disciplina codTurma = do
    putStrLn "Digite a matrícula do aluno que deseja alocar as notas ou ENTER para sair "
    matriculaAluno <- getLine
    if (matriculaAluno == "") then putStrLn "Registro de notas finalizado!"
    else do
        alunoValido <- Modules.GerenciadorOpcoesDisciplina.verificarAlunoTurma disciplina codTurma matriculaAluno
        if (alunoValido) then do 
            menuNotas disciplina codTurma matriculaAluno
            adicionarNotasTurmaController disciplina codTurma
        else do 
            putStrLn "Aluno não existe" 
            adicionarNotasTurmaController disciplina codTurma

salvarNotaController :: String -> String -> String -> String -> IO()
salvarNotaController disciplina codTurma matriculaAluno escolha = do
    putStrLn "Digite o valor da nota: "
    nota <- getLine
    notaSalva <- Modules.GerenciadorOpcoesDisciplina.salvarNota  disciplina codTurma matriculaAluno escolha nota
    putStrLn (notaSalva)

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

-- Função para exibir o menu principal
menuDeQuiz :: String -> IO ()
menuDeQuiz disciplina = do
    putStrLn "\n===== MENU QUIZZ ======"
    putStrLn ""
    putStrLn "[1] Criar Quiz"
    putStrLn "[2] Adicionar pergunta a um Quiz"
    putStrLn "[3] Sair"
    opcao <- getLine
    case opcao of
        "1" -> criarQuizController disciplina
        "2" -> escolherQuizController disciplina
            
        "3" -> putStrLn "Saindo..."
      --  _   -> do
      --      putStrLn "Opção inválida. Tente novamente."
      --      menuDeQuiz quiz

-- Função para interagir com o professor e adicionar uma nova pergunta ao quiz
--adicionarPerguntaMenu :: Quiz -> IO ()
--adicionarPerguntaMenu quiz = do
--    putStrLn "\nDigite a pergunta:"
--    texto <- getLine
--    putStrLn "A resposta é verdadeira? (s/n)"
--    respostaStr <- getLine
--    let resposta = respostaStr == "s" || respostaStr == "S"
 --   let novoQuiz = Modules.GerenciadorOpcoesDisciplina.adicionarPergunta quiz texto resposta
  --  putStrLn "Pergunta adicionada com sucesso!"
  --  menuDeQuiz novoQuiz

-- Função para imprimir um quiz, considerando se está vazio ou não
--imprimirQuiz :: Quiz -> IO ()
--imprimirQuiz quiz
--    | null quiz = putStrLn "Quiz vazio."
--    | otherwise = mapM_ (\(i, Pergunta texto _) -> putStrLn $ show i ++ ". " ++ texto) (zip [1..] quiz)

criarQuizController :: String -> IO ()
criarQuizController disciplina = do
    putStrLn "Digite a turma que você quer adicionar o Quiz: "
    codTurma <- getLine
    putStrLn "Qual  o título do Quiz ?"
    titulo <- getLine
    quizValido <- criarQuiz disciplina codTurma titulo
    if quizValido then do
     putStrLn "Quiz criado! Agora adicione as perguntas e as respostas" 
     adicionarPerguntasRespostasController disciplina codTurma titulo
    else do
        putStrLn "Já existe Quiz com esse nome!"

adicionarPerguntasRespostasController :: String -> String -> String -> IO ()
adicionarPerguntasRespostasController disciplina codTurma titulo = do
    putStrLn "Digite a pergunta ou ENTER para sair: "
    pergunta <- getLine
    if pergunta == "" then putStrLn ""
    else do
        putStrLn "Digite a resposta (digite s para verdadeiro e n para falso): "
        resposta <- getLine
        let respostaValida = Modules.GerenciadorOpcoesDisciplina.validarResposta resposta
        if respostaValida then do
            Modules.GerenciadorOpcoesDisciplina.adicionarPergunta disciplina codTurma titulo pergunta resposta 
            putStrLn ""
            else do
                putStrLn "Digite apenas s para verdadeiro ou n para falso "
                adicionarPerguntasRespostasController disciplina codTurma titulo

escolherQuizController :: String -> IO ()
escolherQuizController disciplina = do
    putStrLn "Digite o código da turma: "
    codTurma <- getLine
    putStrLn "Digite o titulo do Quiz que você quer adicionar uma pergunta: "
    titulo <- getLine
    adicionarPerguntasRespostasController disciplina codTurma titulo
                