:- module(aluno, [aluno_menu/1]).
:- use_module("../utils/Utils").
:- use_module("./Turmas").


aluno_menu(Matricula):-
    write("\n===== MENU DO ALUNO "), write(Matricula), write(" ====\n"),
    printar_todas_turmas(Matricula), nl,
    write("\nDigite a disciplina que você deseja entrar ou 'q' para sair: \n"),
    read(Disciplina),
    write("\nDigite a turma que você dessa disciplina que você deseja entrar ou 'q' para sair: \n"),
    read(CodTurma),
    convert_to_string(Disciplina, D),
    convert_to_string(CodTurma, C),
    ((D == "q"; C == "q") -> nl ;
        ((turma_valida(Matricula, D, C)) -> 
            aluno_menu_turma(Matricula, Disciplina, CodTurma) ;
            write("\nDisciplina ou turma inválida!\n")),
            aluno_menu(Matricula)).

turma_valida(Matricula, Disciplina, CodTurma):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    member([Disciplina, CodTurma], Dados.turmas).

aluno_menu_turma(Matricula, Disciplina, CodTurma):- 
    string_upper(Disciplina, D),
    string_upper(CodTurma, C),
    write("\n==== Menu do aluno "), write(Matricula), write(", na disciplina "), write(D), write(" na turma "), write(C), write("! ===="), nl,
    write("Digite uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Ver notas\n"),
    write("[2] Ver Mural\n"),
    write("[3] Chat\n"),
    write("[4] Avaliar professor(a)\n"),
    write("[5] Materiais Didáticos\n"),
    write("[6] Responder quiz\n"),
    write("==============================================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") -> nl;
        (escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, Op), aluno_menu_turma(Matricula, Disciplina, CodTurma))).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "1"):- situacao_aluno(Disciplina, CodTurma, Matricula).
escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "4"):- avaliar_prof_menu(Disciplina, CodTurma, Matricula), aluno_menu_turma(Matricula, Disciplina, CodTurma).
escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, _):- write("\nOPÇÃO INVÁLIDA\n").


printar_todas_turmas(Matricula):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    printar_turmas(Dados.turmas).

printar_turmas([]).
printar_turmas([[Disciplina|[Turma | _]]|T]):- 
    nl, write("Disciplina: "), write(Disciplina), write(" | Turma: "), write(Turma), printar_turmas(T).

avaliar_prof_menu(Disciplina, CodTurma, Matricula):-
    write("\nAVALIAÇÃO DE DESEMPENHO DO PROFESSOR =====\n"),
    write("Digite uma opção ou 'q' para sair: \n"),
    write("[1] Péssimo\n"),
    write("[2] Ruim\n"),
    write("[3] Ok\n"),
    write("[4] Bom\n"),
    write("[5] Excelente\n"),
    write("==========================================\n"),
    read(Nota),
    (Nota \= 'q' ->
        ((Nota \= 1, Nota \= 2, Nota \= 3, Nota \= 4, Nota \= 5) ->
            write("\nOpção inválida!\n"), avaliar_prof_menu(Disciplina, CodTurma, Matricula)
        ;   registra_avaliacao_prof(Disciplina, CodTurma, Matricula, Nota))
    ;   write("")).

registra_avaliacao_prof(Disciplina, CodTurma, Matricula, Nota):-
    write("\nComentário: (digite 'nn' para não registrar um comentário)\n"),
    read(Comentario),
    convert_to_string(Comentario, C),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/avaliacoes/", Matricula, ".json"], AvaliacaoPath),
    (C \= "nn" ->
        write_json(AvaliacaoPath, _{comentario : C, nota : Nota}),
        write("\nAvaliação registrada!\n")
    ;   write_json(AvaliacaoPath, _{comentario : "", nota : Nota}),
        write("\nAvaliação registrada!\n")).