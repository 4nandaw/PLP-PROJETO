:- module(aluno, [aluno_menu/1]).
:- use_module("../utils/Utils").
:- use_module("./Turmas").
:- use_module("./Quizzes", [escolher_quiz/2]).
:- use_module(library(readutil)).
:- set_prolog_flag(encoding, utf8).

aluno_menu(Matricula):-
    print_blue_bold("\n===== MENU DO ALUNO "), print_blue_bold(Matricula), print_blue_bold(" ====\n"),
    printar_todas_turmas(Matricula), nl,
    print_blue("\nDigite a DISCIPLINA que você deseja entrar ou "), print_white_bold("ENTER"), print_blue(" para sair: \n"),
    read_line_to_string(user_input, Disciplina),
    print_blue("\nDigite a TURMA que você deseja entrar ou "), print_white_bold("ENTER"), print_blue(" para sair: \n"),
    read_line_to_string(user_input, CodTurma),
    convert_to_string(Disciplina, D),
    convert_to_string(CodTurma, C),
    ((D == ""; C == "") -> nl ;
        ((turma_valida(Matricula, D, C)) -> 
            aluno_menu_turma(Matricula, Disciplina, CodTurma) ;
            print_red("\nDisciplina e/ou turma inválida.\n")),
            aluno_menu(Matricula)).

turma_valida(Matricula, Disciplina, CodTurma):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    member([Disciplina, CodTurma], Dados.turmas).

aluno_menu_turma(Matricula, Disciplina, CodTurma):- 
    string_upper(Disciplina, D),
    string_upper(CodTurma, C),
    print_blue_bold("\n==== Menu do aluno "), print_blue_bold(Matricula), print_blue_bold(" na disciplina "), print_blue_bold(D), print_blue_bold(" na turma "), print_blue_bold(C), print_blue_bold("! ====\n"),
    print_blue("Digite uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Ver notas\n"),
    write("[2] Ver Mural\n"),
    write("[3] Chat\n"),
    write("[4] Avaliar professor(a)\n"),
    write("[5] Materiais Didáticos\n"),
    write("[6] Responder quiz\n"),
    print_blue_bold("========================================================\n"),
    read_line_to_string(user_input, Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") -> nl;
        (escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, Op), aluno_menu_turma(Matricula, Disciplina, CodTurma))).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "1"):- situacao_aluno(Disciplina, CodTurma, Matricula).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "3"):- chat_aluno(Matricula, Disciplina, CodTurma).

escolher_opcao_menu_turma(_, Disciplina, CodTurma, "2"):- ver_mural(Disciplina, CodTurma).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "4"):- avaliar_prof_menu(Disciplina, CodTurma, Matricula).

escolher_opcao_menu_turma(_, Disciplina, CodTurma, "5"):- ver_materiais_didaticos(Disciplina, CodTurma).

escolher_opcao_menu_turma(_, Disciplina, CodTurma, "6"):- escolher_quiz(Disciplina, CodTurma).

escolher_opcao_menu_turma(_, _, _, _):- print_red("\nOpção inválida.\n").

printar_todas_turmas(Matricula):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    printar_turmas(Dados.turmas).

printar_turmas([]).
printar_turmas([[Disciplina|[Turma | _]]|T]):- 
    print_blue("\nDisciplina: "), print_white_bold(Disciplina), print_blue(" | Turma: "), print_white_bold(Turma), printar_turmas(T).

avaliar_prof_menu(Disciplina, CodTurma, Matricula):-
    print_blue_bold("\nAVALIAÇÃO DE DESEMPENHO DO PROFESSOR =====\n"),
    print_blue("Digite uma opção ou "), print_white_bold("ENTER"), print_blue(" para sair: \n"),
    write("[1] Péssimo\n"),
    write("[2] Ruim\n"),
    write("[3] Ok\n"),
    write("[4] Bom\n"),
    write("[5] Excelente\n"),
    print_blue_bold("==========================================\n"),
    read_line_to_string(user_input, N),
    trim_whitespace(N, Nota),
    (Nota \= "" ->
        ((Nota \= "1", Nota \= "2", Nota \= "3", Nota \= "4", Nota \= "5") ->
            print_red("\nOpção inválida!\n"), avaliar_prof_menu(Disciplina, CodTurma, Matricula)
        ;   number_string(NotaNumber, Nota),
            registra_avaliacao_prof(Disciplina, CodTurma, Matricula, NotaNumber))
    ;   write("")).

registra_avaliacao_prof(Disciplina, CodTurma, Matricula, Nota):-
    print_blue("\nComentário: (aperte "), print_white_bold("ENTER"), print_blue(" para não registrar um comentário)\n"),
    read_line_to_string(user_input, Comentario),
    convert_to_string(Comentario, C),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/avaliacoes/", Matricula, ".json"], AvaliacaoPath),
    (C \= "ENTER" ->
        write_json(AvaliacaoPath, _{comentario : C, nota : Nota}),
        print_green("\nAvaliação registrada!\n")
    ;   write_json(AvaliacaoPath, _{comentario : "", nota : Nota}),
        print_green("\nAvaliação registrada!\n")).

chat_aluno(Matricula, Disciplina, CodTurma):- 
    print_blue("\nMensagens anteriores: "), acessar_chat(Disciplina, CodTurma, Matricula), print_aviso_chat, enviar_mensagem_chat_aluno(Matricula, Disciplina, CodTurma).

enviar_mensagem_chat_aluno(Matricula, Disciplina, CodTurma):-
    print_white_bold("\nMsg: "),
    read_line_to_string(user_input, Mensagem),
    ((Mensagem == "") -> nl ; 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/chats/", CodTurma, "-", Matricula, ".json"], Path),
        concat_atom(["../db/alunos/", Matricula, ".json"], AlunoPath),
        read_json(AlunoPath, DadosAluno),
        NomeAluno = DadosAluno.nome,
        ((exists_file(Path)) -> 
            (read_json(Path, Dados),
            Chat = Dados.chat,
            append(Chat, [[NomeAluno, Mensagem]], ChatAtualizado),
            put_dict(chat, Dados, ChatAtualizado, DadosGravados),
            write_json(Path, DadosGravados)
            ) ;
            (write_json(Path, _{chat : [[NomeAluno, Mensagem]]}))
        ),
            enviar_mensagem_chat_aluno(Matricula, Disciplina, CodTurma))
    ).
