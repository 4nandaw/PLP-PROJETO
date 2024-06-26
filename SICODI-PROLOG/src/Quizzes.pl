:- module(quizzes, [quiz_menu/2, escolher_quiz/2]).
:- use_module(library(filesex)).
:- use_module(library(http/json)).
:- use_module("../utils/Utils").
:- use_module(library(readutil)).
:- set_prolog_flag(encoding, utf8).

quiz_menu(Disciplina, CodTurma) :- 
    print_purple_bold("\n===== MENU QUIZ ==================\n"),
    write("Digite uma opção: \n"),
    write("[0] Voltar \n"),
    write("[1] Criar Quiz \n"),
    write("[2] Adicionar pergunta a um Quiz \n"),
    print_purple_bold("==================================\n"),
    read_line_to_string(user_input, Opcao),
    escolher_opcao_quiz(Opcao, Disciplina, CodTurma).

escolher_opcao_quiz("0", _, _) :-  nl, !.
escolher_opcao_quiz("1", Disciplina, CodTurma) :-  criar_quiz(Disciplina, CodTurma), !.
escolher_opcao_quiz("2", Disciplina, CodTurma) :-  editar_quiz(Disciplina, CodTurma), !.
escolher_opcao_quiz(_, _, _) :-  print_red("\nOpção inválida\n").

editar_quiz(Disciplina, CodTurma) :- 
    print_purple("\nQual o título do Quiz?\n"),
    read_line_to_string(user_input, Titulo),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/", Titulo, ".json"], QuizPath),

    exists_file(QuizPath) -> (
        read_json(QuizPath, D),
        ler_perguntas_respostas(D.perguntas, D.respostas, Perguntas, Respostas),
        write_json(QuizPath, _{perguntas: Perguntas, respostas: Respostas})
    ).

criar_quiz(Disciplina, CodTurma) :- 
    print_purple("\nQual o título do Quiz?\n"),
    read_line_to_string(user_input, Titulo),
    (Titulo \= "") ->
    ((\+ validar_titulo(Titulo, Disciplina, CodTurma)) -> (
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/"], DirectoryQuizzesPath),
        make_directory_path(DirectoryQuizzesPath),
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
        (\+ exists_file(QuizzesPath) -> (write_json(QuizzesPath, _{quizzes: []})); nl),
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/", Titulo, ".json"], QuizPath),
        
        ler_perguntas_respostas([], [], Perguntas, Respostas),
        write_json(QuizPath, _{perguntas: Perguntas, respostas: Respostas}),
        read_json(QuizzesPath, QuizzesD),
        append(QuizzesD.quizzes, [Titulo], QuizzesNovo),
        write_json(QuizzesPath, _{quizzes: QuizzesNovo}),
        print_green("\nQuiz criado!\n")
    ); print_red("\nJá existe um quiz com esse título!\n")
    ) ; print_red("\nTítulo inválido!\n").


ler_perguntas_respostas(P1, R1, Perguntas, Respostas) :- 
    print_purple_bold("\n============ NOVA PERGUNTA ============\n"),
    print_purple("Digite uma pergunta ou "), print_white_bold("ENTER"), print_purple(" para sair: \n"),
    read_line_to_string(user_input, Read), convert_to_string(Read, P),
    (P \= "") -> (
        append(P1, [P], P2), 
        print_green("\nPergunta adicionada!\n"),

        print_purple("\nDigite a resposta (digite "), print_white_bold("V"), print_purple(" para verdadeiro e "), print_white_bold("F"), print_purple(" para falso): \n"),
        read_line_to_string(user_input, Read1), convert_to_string(Read1, R),
        (R == "V"; R == "F") -> (
            append(R1, [R], R2), 
            ler_perguntas_respostas(P2, R2, Perguntas, Respostas)
        );
        (print_red("\nDigite apenas V para verdadeiro ou F para falso.\n"), 
        ler_perguntas_respostas(P1, R1, Perguntas, Respostas))
        
    ) ; Perguntas = P1, Respostas = R1.

escolher_quiz(Disciplina, CodTurma) :- 
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
    (not_exists_file(QuizzesPath) -> print_red("\nNão há quizzes para serem respondidos!\n") ;
        print_blue_bold("\n======== LISTA DE QUIZZES ========\n"),
        listar_quizzes(Disciplina, CodTurma),
        print_blue_bold("\n======= ESCOLHA QUAL QUIZ VOCÊ QUER RESPONDER =======\n"),
        print_red("Atenção: "), print_white_bold("Ao entrar no quiz, ele só irá fechar após responder todas as perguntas!\n"),
        print_blue("\nDigite o título do quiz: \n"),
        read_line_to_string(user_input, Titulo),
        validar_titulo(Titulo, Disciplina, CodTurma) -> (
            responder_perguntas(Titulo, Disciplina, CodTurma),
            print_green("Quiz respondido!\n")
        ) ; print_red("\nTítulo inválido.\n")
    ).

responder_perguntas(Titulo, Disciplina, CodTurma) :-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/", Titulo, ".json"], QuizPath),
    read_json(QuizPath, Quiz),
    realizar_perguntas(Quiz.perguntas, [], RespostasAluno),
    print_blue_bold("\n====== RESPOSTAS ======\n"),
    exibir_respostas(Quiz.perguntas, Quiz.respostas, RespostasAluno).

exibir_respostas([], [], []) :- !.
exibir_respostas([Pergunta|Perguntas], [QResposta|QRespostas], [AResposta|ARespostas]) :-
    print_blue("\nPergunta: "), write(Pergunta),
    print_blue("\nResposta Correta: "), print_green(QResposta), 
    print_blue("\nSua resposta: "), ((QResposta =:= AResposta) -> print_green(AResposta); print_red(AResposta)), nl, nl,
    exibir_respostas(Perguntas, QRespostas, ARespostas).

realizar_perguntas([], R1, Respostas) :-
    Respostas = R1.

realizar_perguntas([Pergunta|Perguntas], R1, Respostas) :-
    nl, print_blue_bold(Pergunta), nl,
    write("Digite a resposta, apenas "), print_blue_bold("V"), write(" para verdadeiro e "), print_blue_bold("F"), write(" para falso: \n"),
    read_line_to_string(user_input, Read), convert_to_string(Read, R),
    ( (R == "V"; R == "F") ->
        (
            append(R1, [R], R2),
            realizar_perguntas(Perguntas, R2, Respostas)
        )
    ;
        (
            print_red("\nOpção inválida, tente novamente.\n"),
            realizar_perguntas([Pergunta|Perguntas], R1, Respostas)
        )
    ).


validar_titulo(Titulo, Disciplina, CodTurma) :-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes/", Titulo, ".json"], QuizPath),
    exists_file(QuizPath).

listar_quizzes(Disciplina, CodTurma) :- 
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/quiz/quizzes.json"], QuizzesPath),
    read_json(QuizzesPath, D),
    remove_pontos(D.quizzes, Lista),
    print_quizzes(Lista).

print_quizzes([]).
print_quizzes([Quiz|Quizzes]) :-
    print_white_bold(Quiz), nl,
    print_quizzes(Quizzes).