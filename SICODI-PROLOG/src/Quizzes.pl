:- module(quizzes, [quiz_menu/2, escolher_quiz/2]).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module("./utils/Utils").

quiz_menu(Disciplina, CodTurma) :- 
    print_purple_bold("\n===== MENU QUIZ ======\n"),
    write("Digite uma opção: \n"),
    write("[0] Voltar \n"),
    write("[1] Criar Quiz \n"),
    write("[2] Adicionar pergunta a um Quiz \n"),
    print_purple_bold("======================\n"),
    read(Opcao),
    escolher_opcao_quiz(Opcao, Disciplina, CodTurma).

escolher_opcao_quiz(1, Disciplina, CodTurma) :-  criar_quiz(Disciplina, CodTurma), !.
escolher_opcao_quiz(2, Disciplina, CodTurma) :-  editar_quiz(Disciplina, CodTurma), !.

editar_quiz(Disciplina, CodTurma) :- 
    print_purple("\nQual o título do Quiz?\n"),
    read(Titulo),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes", Titulo, ".json"], QuizPath),

    exists_file(QuizPath) -> (
        read_json(QuizPath, D),
        ler_perguntas_respostas(D.perguntas, D.respostas, Perguntas, Respostas),
        write_json(QuizPath, _{perguntas: Perguntas, respostas: Respostas})
    ).

criar_quiz(Disciplina, CodTurma) :- 
    print_purple("\nQual o título do Quiz?\n"),
    read(Titulo),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes"], DirectoryQuizzesPath),
    make_directory_path(DirectoryQuizzesPath),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/", Titulo, ".json"], QuizPath),
    ler_perguntas_respostas([], [], Perguntas, Respostas),
    write_json(QuizPath, _{perguntas: Perguntas, respostas: Respostas}),
    print_green("\nQuiz criado! Agora adicione as perguntas e as respostas!\n").

ler_perguntas_respostas(P1, R1, Perguntas, Respostas) :- 
    ler_perguntas(P1, Perguntas, Fim),
    \+ Fim -> ler_respostas(R1, Respostas).

ler_perguntas(P1, [Pergunta|P1], Fim) :-
    print_purple_bold("\n============ NOVA PERGUNTA ============\n"),
    print_purple("Digite uma pergunta ou "), print_white_bold("q"), print_purple(" para sair: \n"),
    read(Read), convert_to_string(Read, P),
    (P \== "q") -> (Pergunta = P, print_green("\nPergunta adicionada!\n")), Fim = false; Fim = true.

ler_respostas(R1, [Resposta|R1]) :-
    print_purple("\nDigite a resposta (digite "), print_white_bold("V"), print_purple(" para verdadeiro e "), print_white_bold("F"), print_purple(" para falso): \n"),
    read(Read), convert_to_string(Read, R),
    (R == "V"; R == "v"; R == "F"; R == "f") -> Resposta = R ;
    print_red("\nDigite apenas V para verdadeiro ou F para falso.\n"), ler_respostas(R1, [R1, Resposta]).

escolher_quiz(Disciplina, CodTurma) :- 
    print_blue_bold("\n======== LISTA DE QUIZZES ========\n"),
    listar_quizzes(Disciplina, CodTurma),
    print_blue_bold("\n======= ESCOLHA QUAL QUIZ VOCÊ QUER RESPONDER =======\n"),
    print_red("Atenção: "), print_white("Ao entrar no quiz, ele só irá fechar após responder todas as perguntas!"),
    print_blue("\nDigite o título do quiz: "),
    read(Titulo),
    validar_titulo(Titulo, Disciplina, CodTurma) -> (
        responder_perguntas(Titulo, Disciplina, CodTurma),
        print_blue("Quiz respondido!")
    ) ; print_red("Título inválido").

responder_perguntas(Titulo, Disciplina, CodTurma) :-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes", Titulo, ".json"], QuizPath),
    read_json(QuizPath, quiz),
    realizar_perguntas(quiz.perguntas, RespostasAluno),
    print_blue("\n ====== Respostas ======\n"),
    exibir_respostas(quiz.perguntas, quiz.respostas, RespostasAluno)

exibir_respostas([Pergunta|Perguntas], [QResposta|QRespostas], [AResposta|ARespostas]) :-
    print_blue("\n Pergunta: "), print_white(Pergunta),
    print_blue("\nResposta Correta: "), print_green(QResposta), 
    print_blue("\nSua resposta: "), ((QResposta =:= AResposta) -> print_green(AResposta); print_red(AResposta)), 
    exibir_respostas(Perguntas, QRespostas, ARespostas).

realizar_perguntas([Pergunta|Perguntas], Respostas) :- 
    print_blue(Pergunta), nl
    print_white("Digite a resposta, apenas "), print_blue("V"), print_white(" para verdadeiro e "), print_blue("F"), print_white(" para falso:")
    read(Read), convert_to_string(Read, R),
    ((R == "V"; R == "v"; R == "F"; R == "f") -> (
        Respostas = [Respostas|R],
        realizar_perguntas(Perguntas, Respostas)
    ) ; write_red("Opção Inválida!")),
    realizar_perguntas([Pergunta|Perguntas], Respostas).

validar_titulo(Titulo, Disciplina, CodTurma) :-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes", Titulo, ".json"], QuizPath),
    exists_file(QuizPath).

listar_quizzes(Disciplina, CodTurma) :- 
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
    read_json(QuizzesPath, D),
    remove_pontos(D, Lista),
    print_quizzes(Lista).

print_quizzes([Quiz|Quizzes]) :-
    print_blue(Quiz), nl,
    print_quizzes(Quizzes).
