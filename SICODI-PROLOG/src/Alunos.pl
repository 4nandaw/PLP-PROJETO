:- module(aluno, [aluno_menu/1]).
:- use_module("../utils/Utils").
:- use_module("./Turmas").

aluno_menu(Matricula):-
    print_blue_bold("\n"),
    print_blue_bold("===== MENU DO ALUNO "), print_blue_bold(Matricula), print_blue_bold(" ===="), nl,
    printar_todas_turmas(Matricula), nl, nl,
    print_blue("Digite a DISCIPLINA que você deseja entrar ou "), print_white_bold('q'), print_blue(" para sair:"), nl,
    read(Disciplina), nl,
    print_blue("Digite a TURMA que você deseja entrar ou "), print_white_bold('q'), print_blue(" para sair:"), nl,
    read(CodTurma),
    convert_to_string(Disciplina, D),
    convert_to_string(CodTurma, C),
    ((D == "q", C == "q") -> nl ;
        ((turma_valida(Matricula, D, C)) -> 
            aluno_menu_turma(Matricula, Disciplina, CodTurma) ;
            print_red("\nDisciplina e/ou turma inválida.\n")),
            aluno_menu(Matricula)).

turma_valida(Matricula, Disciplina, CodTurma):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    member([Disciplina, CodTurma], Dados.turmas).

aluno_menu_turma(Matricula, Disciplina, CodTurma):- 
    nl, 
    print_blue_bold("==== Menu do aluno "), print_white_bold(Matricula), print_blue_bold(" na disciplina "), print_white_bold(Disciplina), print_blue_bold(" na turma "), print_white_bold(CodTurma), print_blue_bold("! ===="), nl,
    print_blue("Digite uma opção: "), nl,
    print_blue("[0] Voltar"), nl,
    print_blue("[1] Ver notas"), nl,
    print_blue("[2] Ver Mural"), nl,
    print_blue("[3] Chat"), nl,
    print_blue("[4] Avaliar professor(a)"), nl,
    print_blue("[5] Materiais Didáticos"), nl,
    print_blue("[6] Responder quiz"), nl,
    print_blue_bold("========================================================"), nl,
    read(Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") -> nl;
        (escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, Op), aluno_menu_turma(Matricula, Disciplina, CodTurma))).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "1"):- situacao_aluno(Disciplina, CodTurma, Matricula).
escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, _):- print_red("\nOpção inválida.\n").

printar_todas_turmas(Matricula):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    printar_turmas(Dados.turmas).

printar_turmas([]).
printar_turmas([[Disciplina|[Turma | _]]|T]):- 
    nl, print_blue("Disciplina: "), print_white_bold(Disciplina), print_blue(" | Turma: "), print_white_bold(Turma), printar_turmas(T).
