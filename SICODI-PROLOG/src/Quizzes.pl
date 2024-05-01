:- module(quizzes, [quiz_menu/2])
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module("./utils/Utils").

quiz_menu(Disciplina, CodTurma) :- 
    print_purple_bold("\n===== MENU QUIZ ======"),
    print_purple("Digite uma opção: \n"),
    print_purple("[0] Voltar \n"),
    print_purple("[1] Criar Quiz \n"),
    print_purple("[2] Adicionar pergunta a um Quiz \n"),
    print_purple_bold("======================"),
    read(Opcao),
    escolher_opcao_quiz(Opcao).

escolher_opcao_quiz(1, Disciplina, CodTurma) :-  criar_quiz(Disciplina, CodTurma), !.

criar_quiz(Disciplina, CodTurma) :- 
    print_purple("\nQual o título do Quiz?"),
    read(Titulo),

    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
    ((\+ exists_file(QuizzesPath)) -> make_directory_path(QuizPath), write_json(QuizzesPath, _{quizzes: []})),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes", Titulo, ".json"], QuizPath),

    print_green("\nQuiz criado! Agora adicione as perguntas e as respostas!\n"),

    ler_perguntas_respostas(Perguntas, Respostas),
    write_json(QuizPath, _{perguntas: Perguntas, respostas: Respostas}).

    \nQuiz criado! Agora adicione as perguntas e as respostas!\n

ler_perguntas_respostas(Perguntas, Respostas) :- .
    ler_perguntas([], Perguntas, Fim),
    \+ Fim -> ler_respostas([], Respostas).

ler_perguntas([H|T], [[H|T], Pergunta], Fim) :-
    print_purple_bold("============ NOVA PERGUNTA ============\n")
    print_purple("Digite uma pergunta ou"), print_white_bold("q"), print_purple(" para sair: ")
    read(P),
    (P =\= "q") -> (Pergunta = P, print_green("\nPergunta adicionada\n")); Fim = true.

ler_respostas([H|T], [[H|T], Resposta]) :-
    print_purple("\nDigite a resposta (digite "), print_white_bold("V"), print_purple(" para verdadeiro e "), print_white_bold("F") print_purple(" para falso): ")
    read(R),
    (R =:= "V"; R =:= "v"; R =:= "F"; R =:= "f") -> Resposta = R ;
    print_red("\nDigite apenas V para verdadeiro ou F para falso.\n"), ler_respostas([H|T], [[H|T], Resposta]).