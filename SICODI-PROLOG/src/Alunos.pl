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
escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, _):- write("\nOPÇÃO INVÁLIDA\n").


printar_todas_turmas(Matricula):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    printar_turmas(Dados.turmas).

printar_turmas([]).
printar_turmas([[Disciplina|[Turma | _]]|T]):- 
    nl, write("Disciplina: "), write(Disciplina), write(" | Turma: "), write(Turma), printar_turmas(T).
