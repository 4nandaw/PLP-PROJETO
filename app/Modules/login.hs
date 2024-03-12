    module Modules.Login where


    --verificarMatricula :: String -> String -> IO ()
    --verificarSenhaProfessor :: String-> String -> IO ()
    --verificarSenhaAluno :: String -> String -> IO ()
    --verificarNomeDisciplina :: String -> IO ()
    loginProfessor :: IO()
    loginAluno :: IO()
    escolherLogin :: String -> IO()
    escolherOpcaoLogin :: IO()
    loginGeral :: IO()


    loginGeral = do
        putStrLn "Login ====================="
        putStrLn "Digite uma opção: "       
        putStrLn "[0] Voltar pro menu inicial"
        putStrLn "[1] Login de professor"
        putStrLn "[2] Login de aluno"
        putStrLn "=============================="
        escolherOpcaoLogin

    escolherOpcaoLogin = do
        escolha <- getLine 
        escolherLogin escolha

    escolherLogin escolha 
        |(escolha == "0") = putStr ""
        |(escolha == "1") = loginProfessor
        |(escolha == "2") = loginAluno
        | otherwise = putStrLn "Opção Inválida" 



    --É preciso duas funções para verificar senha diferentes, pois os arquivos relacionados aos professores estão num caminho
    -- diferente dos relacionados aos alunos, mas pode-se otimizar isso mais a frente passando como argumento na função 
    -- 0 para aluno e 1 para professor.  


    --FUNÇÕES COM ERROS DE DECLARAÇÃO/TIPO
    --verificarNomeDisciplina nomeDisciplia = putStrLn ("*VERIFICANDO NOME DA DISCIPLINA * // NÃO ESTÁ FEITO AINDA " ++ nomeDisciplia)

    --verificarSenhaProfessor nomeDisciplina senha = putStrLn ("*VERIFICANDO SENHA DO PROFESSOR* // NÃO ESTÁ FEITO AINDA " ++ nomeDisciplina ++ " " ++ senha)

    --verificarSenhaAluno matricula senha = putStrLn ("*VERIFICANDO SENHA DO ALUNO* // NÃO ESTÁ FEITO " ++ matricula ++ " " ++ senha)

    --verificarMatricula matricula = putStrLn ("*VERIFICANDO MATRÍCULA DO ALUNO* // NÃO ESTÁ FEITO AINDA " ++ matricula)

    loginProfessor = do
        putStrLn "Digite o nome da disciplina: "
        nomeDisciplia <- getLine
        --verificarNomeDisciplina nomeDisciplia
        putStrLn "Digite a senha: "
        senha <- getLine
        --verificarSenhaProfessor nomeDisciplia senha
        putStrLn " "

    loginAluno = do
        putStrLn "Digite a matrícula do aluno: "
        matricula <- getLine
        --verificarMatricula matricula
        putStrLn "Digite a senha: "
        senha <- getLine
        --verificarSenhaAluno matricula senha
        putStrLn " "
        


