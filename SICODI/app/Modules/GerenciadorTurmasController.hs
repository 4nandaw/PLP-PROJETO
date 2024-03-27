module Modules.GerenciadorTurmasController where
import Modules.GerenciadorTurmas
import System.Directory
import System.Console.Pretty

opcoesDeTurmas :: String -> IO()
opcoesDeTurmas disciplina = do
    putStrLn (color Magenta . style Bold $ "MENU DE TURMAS =====")
    putStrLn "Digite uma opção: "
    putStrLn "[0] Voltar"
    putStrLn "[1] Minhas turmas"
    putStrLn "[2] Criar turma"
    putStrLn "[3] Adicionar aluno"
    putStrLn "[4] Excluir aluno"
    putStrLn "[5] Excluir turma"
    putStrLn (color Magenta "====================")
    escolherOpcaoTurma disciplina

escolherOpcaoTurma :: String -> IO()
escolherOpcaoTurma disciplina = do
    escolha <- getLine
    escolherOpcaoMenuTurmas escolha disciplina
    if (escolha /= "0") then opcoesDeTurmas disciplina
    else putStrLn " "

listarTurmasController :: String -> IO()    
listarTurmasController disciplina = do
    putStrLn (color Magenta "Turmas de " ++ disciplina)

    response <- listarTurmas disciplina
    putStrLn response

    putStrLn (color Magenta "===============================================")
    putStrLn (color Magenta "Informe um codigo de turma, ou ENTER para sair:")
    codigo <- getLine

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/"

    validarTurma <- doesFileExist (diretorio ++ codigo ++ "/" ++ codigo ++ ".json") 
    
    if not validarTurma then putStrLn (color Red "Codigo de turma invalido")
    else do 
        if codigo /= "" then do
            putStrLn "Escolha uma opção: "
            putStrLn "[1] Ver alunos da turma"
            putStrLn "[2] Ver relatório da turma"
            putStrLn "==============================================="
            opcao <- getLine

            if codigo /= "" then do
                if opcao == "1" then do
                    responseAlunos <- verAlunos (diretorio ++ codigo ++ "/alunos/")
                    putStrLn responseAlunos
                else if opcao == "2" then do
                    relatorio <- exibirRelatorio (diretorio ++ codigo ++ "/alunos/")
                    putStrLn relatorio
                else putStrLn "Opção inválida!"
            else putStrLn ""
        else putStrLn "" 

criarTurmaController :: String -> IO()
criarTurmaController disciplina = do
    putStrLn (color Magenta "CADASTRO DE TURMA")
    putStrLn (color Magenta "Nome da turma: ")
    nome <- getLine
    putStrLn (color Magenta "Codigo da turma: ")
    codigo <- getLine

    response <- criarTurma disciplina nome codigo
    putStrLn response

solicitarEAlocarAlunoController :: String -> IO()
solicitarEAlocarAlunoController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma: ")
    codigo <- getLine

    response <- solicitarEAlocarAluno disciplina codigo

    if response /= "Codigo inválido!" then do
        putStrLn (color Magenta "Informe a matricula: ")
        m <- getLine
        alocarAlunoController m disciplina codigo
    else putStrLn ""

alocarAlunoController :: String -> String -> String -> IO()
alocarAlunoController matricula disciplina codigo = do
    if matricula == "" then putStrLn (color Green "Registro finalizado!")
    else do
        alocarAluno matricula disciplina codigo

        putStrLn (color Magenta "Informe o proximo aluno (matricula) ou ENTER para finalizar: ")
        m <- getLine
        
        alocarAlunoController m disciplina codigo

excluirAlunoController :: String -> IO()
excluirAlunoController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma: ")
    codigo <- getLine
    
    response <- excluirAluno disciplina codigo

    if response /= "Turma invalida!" then do 
        putStrLn (color Magenta "Informe a matricula do aluno: ")
        matricula <- getLine

        responseAluno <- removerAluno disciplina matricula codigo
        putStrLn responseAluno
    else putStrLn (color Red "Turma invalida!")

excluirTurmaController :: String -> IO()
excluirTurmaController disciplina = do
    putStrLn (color Magenta "Informe o codigo da turma a ser excluida: ")
    codigo <- getLine

    response <- excluirTurma disciplina codigo
    putStrLn response

escolherOpcaoMenuTurmas :: String -> String -> IO()
escolherOpcaoMenuTurmas escolha disciplina
        | (escolha == "0") = putStrLn " "
        | (escolha == "1") = listarTurmasController disciplina
        | (escolha == "2") = criarTurmaController disciplina
        | (escolha == "3") = solicitarEAlocarAlunoController disciplina
        | (escolha == "4") = excluirAlunoController disciplina
        | (escolha == "5") = excluirTurmaController disciplina
        | otherwise = putStrLn (color Red "Opção Inválida!")