{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Modules.GerenciadorOpcoesDisciplina where


import Utils.AlunoTurma
import Utils.Chat
import Utils.Mural
import Utils.Avaliacao
import Utils.Aluno
import Utils.Disciplina
import Utils.MaterialDidatico
import Utils.Quizzes
import Utils.Quiz
import GHC.Generics
import qualified Data.ByteString.Lazy as B
import System.Directory
import Data.Aeson
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import System.FilePath.Posix (takeDirectory)
import Data.Maybe (isJust)
import Text.Read (readMaybe)
import Text.Printf
import Numeric 
import Data.List (intercalate)
import System.Console.Pretty
import Data.Char



solicitarEAlocarNotas :: String -> String -> IO Bool
solicitarEAlocarNotas disciplina codTurma = do
    turmaValida <- doesDirectoryExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma)
    if turmaValida then do 
        return True
    else return False

validarNota :: String -> IO Bool
validarNota notaStr =
    case readMaybe notaStr :: Maybe Float of
        Just nota -> return (nota>=0 && nota<=10)
        Nothing -> return False

mediaFaltas :: String -> String -> IO String
mediaFaltas disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos"

    listaDeAlunos <- getDirectoryContents diretorio

    let faltasAlunos = mapM (\x -> exibirFaltas x diretorio) listaDeAlunos
    faltas <- faltasAlunos

    let faltasValidas = filter (> -1) faltas
    let tamanho = length faltasValidas

    if tamanho > 0
        then do
            let totalFaltas = sum faltasValidas
            let media = fromIntegral totalFaltas / fromIntegral tamanho
            return $ (color White . style Bold $ "Média de faltas: ") ++ show media
        else
            return $ (color White . style Bold $ "Não há alunos registrados para calcular a média de faltas.")

mediaNotas :: String -> String -> IO String
mediaNotas disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos"

    listaDeAlunos <- getDirectoryContents diretorio

    let notasAlunos = mapM (\x -> exibirNotas x diretorio) listaDeAlunos
    notas <- notasAlunos

    let notasValidas = filter (> -1) notas
    let tamanho = length notasValidas

    if tamanho > 0
        then do 
            let totalNotas = sum notasValidas
            let media = totalNotas / fromIntegral tamanho
            return $ (color White . style Bold $ "Média de notas: ") ++ show media
    else
        return $ (color White . style Bold $ "Não há alunos registrados para calcular a média de notas.")

atualizarMedia :: String -> String -> String -> IO String
atualizarMedia disciplina codTurma matriculaAluno = do
    let diretorio = ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    dados <- B.readFile diretorio
    case decode dados of
        Just (AlunoTurma nota1 nota2 nota3 _ faltas)-> do
            let media = printf "%.1f" ((nota1 + nota2 + nota3)/3)
                mediaF = read media :: Float
                alunoMediaAtualizada = AlunoTurma nota1 nota2 nota3 mediaF faltas
            B.writeFile diretorio (encode alunoMediaAtualizada)
            return "Média atualizada"
        Nothing -> return "Erro na atualização da média"

verAlunos :: String -> String -> IO String
verAlunos disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/"

    listaDeAlunos <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    response <- mapM (\x -> (exibirAluno x diretorio)) listaDeAlunos

    return (unlines $ response)

exibirAluno :: String -> String -> IO String
exibirAluno matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioInfo = "./db/alunos/" ++ matricula
        let diretorioA = diretorio ++ matricula

        aluno <- B.readFile diretorioInfo
        alunoFaltas <- B.readFile diretorioA

        nome <- case decode aluno of 
            Just (Aluno nome _ _ _) -> return $ nome
            Nothing -> return ""

        matriculaDecode <- case decode aluno of 
            Just (Aluno _ matricula _ _ ) -> return $ matricula
            Nothing -> return ""

        faltas <- case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ _ faltas) -> return $ faltas
            Nothing -> return 0

        return (color White . style Bold $ (matriculaDecode ++ " - " ++ nome ++ " ----- " ++ (show faltas) ++ " falta(s)"))
      else return ""

exibirFaltas :: String -> String -> IO Int
exibirFaltas matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioAluno = diretorio ++ "/" ++ matricula
        
        alunoFaltas <- B.readFile diretorioAluno

        case decode alunoFaltas of 
            Just (AlunoTurma _ _ _ _ faltas) -> return faltas
            _ -> return (-1)
    else return (-1)

exibirNotas :: String -> String -> IO Float
exibirNotas matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioAluno = diretorio ++ "/" ++ matricula
        
        alunoNotas <- B.readFile diretorioAluno

        case decode alunoNotas of 
            Just (AlunoTurma _ _ _ notas _) -> return notas
            _ -> return (-1)
    else return (-1)

exibirAvaliacao :: String -> String -> IO String
exibirAvaliacao arquivo diretorio = do
    if arquivo /= "." && arquivo /= ".." then do
        let caminho = diretorio ++ arquivo

        avaliacao <- B.readFile caminho

        nota <- case decode avaliacao of 
            Just (Avaliacao nota _) -> return $ show nota
            Nothing -> return ""

        comentario <- case decode avaliacao of 
            Just (Avaliacao _ comentario) -> return comentario
            Nothing -> return ""

        notaFormatada <- formataNota nota

        return (notaFormatada ++ "\n" ++ (color White . style Bold $ "Comentário: ") ++ comentario ++ "\n")
    else return ""

formataNota :: String -> IO String
formataNota nota
    | (nota == "1") = return (color Yellow . style Bold $ "⭑☆☆☆☆")
    | (nota == "2") = return (color Yellow . style Bold $ "⭑⭑☆☆☆")
    | (nota == "3") = return (color Yellow . style Bold $ "⭑⭑⭑☆☆")
    | (nota == "4") = return (color Yellow . style Bold $ "⭑⭑⭑⭑☆")
    | (nota == "5") = return (color Yellow . style Bold $ "⭑⭑⭑⭑⭑")
    | otherwise = return ""

exibirNota :: String -> String -> IO Int
exibirNota arquivo diretorio = do
    if arquivo /= "." && arquivo /= ".." then do
        let caminho = diretorio ++ arquivo

        avaliacao <- B.readFile caminho

        case decode avaliacao of 
            Just (Avaliacao nota _) -> return nota
            _ -> return (-1)
    else return (-1)

criarAvisoTurma :: String -> String -> String -> IO String
criarAvisoTurma disciplina codTurma novoAviso = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/mural/"

    let diretorioArquivo = diretorio ++ "mural.json"
    createDirectoryIfMissing True $ takeDirectory diretorioArquivo
    
    muralValido <- doesFileExist diretorioArquivo
    if muralValido then do
        dadosMural <- B.readFile diretorioArquivo
        case decode dadosMural of
            Just (Mural avisosAntigos) -> do
                let muralAtualizado = encode $ Mural { aviso = avisosAntigos ++ [novoAviso] }
                B.writeFile diretorioArquivo muralAtualizado
                return "Aviso registrado no Mural da Turma!"
            Nothing -> do
                let mural = encode $ Mural { aviso = [novoAviso] }
                B.writeFile diretorioArquivo mural
                return "Aviso registrado no Mural da Turma!"
    else do
        let mural = encode $ Mural { aviso = [novoAviso] }
        B.writeFile diretorioArquivo mural
        return "Aviso registrado no Mural da Turma!"

salvarNota :: String -> String -> String -> String -> String -> IO String
salvarNota disciplina codTurma matriculaAluno escolha nota = do
    notaValida <- validarNota nota
    if (notaValida) then do
        dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
        let notaAtualizada = read nota
        case decode dados of
            Just (AlunoTurma nota1 nota2 nota3 media faltas)-> do
                let alunoNotaAtualizada = case escolha of
                        "1" -> AlunoTurma notaAtualizada nota2 nota3 media faltas
                        "2" -> AlunoTurma nota1 notaAtualizada nota3 media faltas
                        "3" -> AlunoTurma nota1 nota2 notaAtualizada media faltas
                        _ -> AlunoTurma nota1 nota2 nota3 media faltas
                B.writeFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json") (encode alunoNotaAtualizada)
                atualizarMedia disciplina codTurma matriculaAluno
                return (color Green "\nNota salva!")
            Nothing -> return (color Red "Erro!")
    else 
        return "Nota inválida"

situacaoAluno :: String -> String -> String -> IO String
situacaoAluno disciplina codTurma matriculaAluno = do
    dados <- B.readFile ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    case decode dados of 
        Just (AlunoTurma nota1 nota2 nota3 media faltas) -> do
            let situacao = if (faltas > 7) then (color Red "Reprovado por faltas :(")
                            else if media >= 7 then (color Green "Aprovado :)")
                                else if media >= 4 && media <= 6.9 then (color Yellow "Final :|")
                                    else (color Red "Reprovado :(")
            return $ (color White . style Bold $ "\n===== SITUAÇÃO DO ALUNO(A) " ++ matriculaAluno ++ " =====\n\n") ++
                     (color White . style Bold $ "Nota 1: ") ++ show nota1 ++ "\n" ++
                     (color White . style Bold $ "Nota 2: ") ++ show nota2 ++ "\n" ++
                     (color White . style Bold $ "Nota 3: ") ++ show nota3 ++ "\n" ++
                     (color White . style Bold $ "Faltas: ") ++ show faltas ++ "\n" ++
                     printf (color White . style Bold $ "Média: %.1f\n") media ++
                     situacao ++ "\n"
        Nothing -> return "Erro: Dados não encontrados para o aluno."

verAvaliacoes :: String -> String -> IO String
verAvaliacoes disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/avaliacoes/"

    listaDeAvaliacoes <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    response <- mapM (\x -> (exibirAvaliacao x diretorio)) listaDeAvaliacoes

    return (unlines $ response)

mediaAvaliacoes :: String -> String -> IO String
mediaAvaliacoes disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/avaliacoes/"

    listaDeAvaliacoes <- getDirectoryContents diretorio

    let notasAvaliacoes = mapM (\x -> exibirNota x diretorio) listaDeAvaliacoes
    notas <- notasAvaliacoes

    let notasValidas = filter (/= -1) notas
    if notasValidas == [] then return $ color Red "\nAinda não há avaliações para o professor"
    else do
        let quantidade = length notasValidas
        let somaNotas = sum notasValidas
        let media = fromIntegral somaNotas / fromIntegral quantidade

        return $ (color White . style Bold $ "Nota média dada ao professor: ") ++ show media

adicionarNotasTurma :: String -> String -> String-> IO Bool
adicionarNotasTurma disciplina codTurma matriculaAluno = do
    alunoValido <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    if (alunoValido) then do 
        return True
    else do 
        return False

verAlunosChat :: String -> String -> IO String
verAlunosChat disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/"

    listaDeAlunos <- getDirectoryContents diretorio

    createDirectoryIfMissing True $ takeDirectory diretorio

    response <- mapM (\x -> (exibirAlunoChat x diretorio)) listaDeAlunos

    return (unlines $ response)

exibirAlunoChat :: String -> String -> IO String
exibirAlunoChat matricula diretorio = do
    if matricula /= "." && matricula /= ".." then do
        let diretorioInfo = "./db/alunos/" ++ matricula

        aluno <- B.readFile diretorioInfo

        nome <- case decode aluno of 
            Just (Aluno nome _ _ _) -> return $ nome
            Nothing -> return ""

        matriculaDecode <- case decode aluno of 
            Just (Aluno _ matricula _ _ ) -> return $ matricula
            Nothing -> return ""

        return (color White . style Bold $ (nome ++ " --- " ++ matriculaDecode))
      else return ""

verificarPossivelChat :: String -> String -> String -> IO Bool
verificarPossivelChat disciplina codTurma matriculaAluno = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma
    turmaValida <-doesDirectoryExist diretorio
    if not turmaValida then return False
    else do 
        let diretorioAluno = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json"
        matriculaAlunoValida <- doesFileExist diretorioAluno
        if matriculaAlunoValida then return True
        else return False

acessarChat :: String -> String -> String -> IO String
acessarChat disciplina codTurma matriculaAluno = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/chats/" ++ codTurma ++ "-" ++ matriculaAluno ++ ".json"
    createDirectoryIfMissing True $ takeDirectory diretorio
    chatExiste <- doesFileExist diretorio

    if not chatExiste then do
        let chat = encode(Chat{chat = []})
        B.writeFile diretorio chat
        return (color White "Ainda não há nenhuma mensagem... inicie a conversa!")
    else do
        dadosChat <- B.readFile diretorio
        nomeProfessor <- puxarNomeProfessor disciplina
        case decode dadosChat of 
            Just (Chat chat) -> do
                let listaMensagensChat = map (\x -> ajustarExibirMensagensChat x nomeProfessor) chat
                if listaMensagensChat == [] then return (color White . style Bold $ "Sem mensagens no chat!")
                else return $ unlines $ listaMensagensChat
            Nothing -> return (color Red "Erro ao pegar as mensagens do chat.")

ajustarExibirMensagensChat :: [String] -> String -> String
ajustarExibirMensagensChat [remetente, mensagem] nomeProfessor
    | (remetente==nomeProfessor) = (color White . style Bold $ nomeProfessor) ++ ": " ++ mensagem
    | otherwise = (color White . style Bold $ remetente) ++ ": " ++ mensagem 

puxarNomeProfessor :: String -> IO String
puxarNomeProfessor disciplina = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/"++ disciplina ++ ".json"
    dados <- B.readFile diretorio
    case decode dados of
        Just (Disciplina _ _ nomeProfessor _) -> return nomeProfessor
        Nothing -> return "Erro ao pegar nome do professor"

verificarAlunoTurma :: String -> String -> String-> IO Bool
verificarAlunoTurma disciplina codTurma matriculaAluno = do
    alunoValido <- doesFileExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json")
    if (alunoValido) then do 
        return True
    else do 
        return False

verificadorArquivoTurma :: String -> String -> IO Bool
verificadorArquivoTurma disciplina codTurma = do
    turmaValida <- doesDirectoryExist ("./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma)
    if turmaValida then do 
        return True
    else return False

adicionarFalta :: String -> String -> String-> IO String
adicionarFalta disciplina codTurma matriculaAluno = do

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/alunos/" ++ matriculaAluno ++ ".json"

    dados <- B.readFile diretorio
    case decode dados of 
        Just (AlunoTurma nota1 nota2 nota3 media faltas) -> do
            let alunoFaltaAtualizada = AlunoTurma nota1 nota2 nota3 media (faltas + 1)
            B.writeFile diretorio (encode alunoFaltaAtualizada)
            return "Faltas do aluno atualizada."
        Nothing -> return "Erro!!!"

criarAvisoMural :: String -> String -> String -> IO String
criarAvisoMural disciplina codTurma novoAviso = do

    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/mural/mural.json"
    createDirectoryIfMissing True $ takeDirectory diretorio
    
    muralValido <- doesFileExist diretorio
    if muralValido then do
        dadosMural <- B.readFile diretorio
        case decode dadosMural of
            Just (Mural avisosAntigos) -> do
                let muralAtualizado = encode $ Mural { aviso = avisosAntigos ++ [novoAviso] }
                B.writeFile diretorio muralAtualizado
                return (color Green "\nAviso registrado no Mural da Turma!")
            Nothing -> do
                let mural = encode $ Mural { aviso = [novoAviso] }
                B.writeFile diretorio mural
                return (color Green "\nAviso registrado no Mural da Turma!")
    else do
        let mural = encode $ Mural { aviso = [novoAviso] }
        B.writeFile diretorio mural
        return (color Green "\nAviso registrado no Mural da Turma!")

exibirAvisosMural :: String -> String -> IO String
exibirAvisosMural disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/mural/" ++ "mural.json"
    muralValido <- doesFileExist diretorio
    if muralValido then do
        dadosMural <- B.readFile diretorio
        case decode dadosMural of
            Just (Mural avisos) -> do
                let novoAviso = (color Blue . style Bold $ "+ ") ++ (last avisos) ++ "\n\n"
                let avisosAnteriores = intercalate "\n\n" (reverse $ init avisos)
                let mensagens = novoAviso ++ avisosAnteriores
                return $ (color White . style Bold $ "\n===== MENSAGENS DO MURAL\n\n") ++ mensagens ++ "\n"
            Nothing -> return "Erro ao decodificar o Mural"
    else
        return (color Red "\nNenhuma mensagem no Mural.")

criarMaterialDidatico :: String -> String -> String -> String -> IO String
criarMaterialDidatico disciplina codTurma titulo conteudo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/materiais/"
    let diretorioArquivo = diretorio ++ "materiaisDidaticos.json"
    createDirectoryIfMissing True $ takeDirectory diretorioArquivo
    
    existeArquivo <- doesFileExist diretorioArquivo
    
    if existeArquivo then do
        dadosMaterial <- B.readFile diretorioArquivo
        case decode dadosMaterial of
            Just (MaterialDidatico materiais) -> do
                let novoMaterial = (titulo, conteudo)
                let materiaisAtualizados = MaterialDidatico (materiais ++ [novoMaterial])
                B.writeFile diretorioArquivo (encode materiaisAtualizados)
                return (color Green "\nMaterial didático registrado com sucesso!\n")
            Nothing -> return (color Red "\nErro!\n")
    else do
        let novoMaterial = MaterialDidatico [(titulo, conteudo)]
        B.writeFile diretorioArquivo (encode novoMaterial)
        return (color Green "\nMaterial didático registrado com sucesso!\n")

exibirMaterialDidatico :: String -> String -> IO String
exibirMaterialDidatico disciplina codTurma = do
    let diretorioArquivo = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/materiais/materiaisDidaticos.json"
    
    existeArquivo <- doesFileExist diretorioArquivo
    
    if existeArquivo then do
        dadosMaterial <- B.readFile diretorioArquivo
        case decode dadosMaterial of
            Just (MaterialDidatico materiais) -> do
                let listaMateriais = formatarMateriais $ reverse materiais
                return $ (color White . style Bold $ "\n===== MATERIAIS DIDÁTICOS =====\n\n") ++ listaMateriais
            Nothing -> return (color Red "\nAinda não há materiais didáticos disponíveis.")
    else
        return (color Red "\nAinda não há materiais didáticos disponíveis.")

formatarMateriais :: [(String, String)] -> String
formatarMateriais [] = ""
formatarMateriais ((titulo, conteudo):resto) = 
    (color White . style Bold $ "Título do Material: ")++ titulo ++ "\n" ++
    (color White . style Bold $ "Conteúdo do Material: ") ++ conteudo ++ "\n\n" ++
    formatarMateriais resto

-- Função para criar um novo quiz vazio
criarQuiz :: String -> String -> String -> IO Bool
criarQuiz disciplina codTurma titulo = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
        diretorioQuizzes = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/" ++ "quizzes.json"
    createDirectoryIfMissing True $ takeDirectory diretorio
    quizValido <- quizExiste disciplina codTurma titulo
    if quizValido then return False
    else do
        quizzesExiste <- doesFileExist diretorioQuizzes
        if quizzesExiste then do
            dados <- B.readFile diretorioQuizzes
            case decode dados of
                Just (Quizzes quizzes) -> do
                    let dadosQuizzes = encode (Quizzes{quizzes = quizzes ++ [titulo]})
                    B.writeFile diretorioQuizzes dadosQuizzes
        else do 
            let dadosQuizzes = encode (Quizzes{quizzes = [titulo]})
            B.writeFile diretorioQuizzes dadosQuizzes
        let quiz = encode (Quiz{perguntas = [], respostas = []})
        B.writeFile diretorio quiz
        return True

listarQuizzes :: String -> String -> IO String
listarQuizzes disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/" ++ "quizzes.json"
    quizzesValidos <- doesFileExist diretorio
    if not quizzesValidos then return $ color Red "\nNão existem quizzes criados!"
    else do 
        dados <- B.readFile diretorio
        case decode dados of
            Just (Quizzes quizzes) -> do
                return $ unlines quizzes

quizExiste :: String -> String -> String -> IO Bool
quizExiste disciplina codTurma titulo = do 
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
    createDirectoryIfMissing True $ takeDirectory diretorio
    quizValido <- doesFileExist diretorio
    return quizValido

validarResposta :: String -> Bool
validarResposta resposta = do
    if map toUpper resposta /= "V" && map toUpper resposta /= "F" then False
    else True

adicionarPergunta :: String -> String -> String -> String -> String -> IO String
adicionarPergunta disciplina codTurma titulo pergunta resposta = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/quizzes/" ++ titulo ++ ".json"
    dados <- B.readFile diretorio
    case decode dados of
        Just (Quiz perguntas respostas) -> do
            let respostaBool = map toUpper resposta == "V"
            let dadosAtualizados = encode (Quiz{perguntas = perguntas ++ [pergunta], respostas = respostas ++ [respostaBool]})
            B.writeFile diretorio dadosAtualizados
            return ""

verificarQuizzesExistentes :: String -> String -> IO Bool
verificarQuizzesExistentes disciplina codTurma = do
    let diretorio = "./db/disciplinas/" ++ disciplina ++ "/turmas/" ++ codTurma ++ "/quiz/" ++ "quizzes.json"
    quizzesExistem <- doesFileExist diretorio
    if quizzesExistem then return True
    else return False