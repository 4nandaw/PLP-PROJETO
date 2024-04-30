:- module(aluno, [aluno_menu/1]).
:- use_module("../utils/Utils").
:- use_module("./Turmas").


aluno_menu(Matricula):-
    write("\n===== MENU DO ALUNO "), write(Matricula), write(" ====\n"),
    printar_todas_turmas(Matricula), nl,
    write("Digite a disciplina que você deseja entrar ou 'q' para sair: \n"),
    read(Disciplina), nl,
    write("Digite a turma que você dessa disciplina que você deseja entrar ou 'q' para sair: \n"),
    read(CodTurma),
    convert_to_string(Disciplina, D),
    convert_to_string(CodTurma, C),
    ((D == "q"; C == "q") -> nl ;
        ((turma_valida(Matricula, D, C)) -> 
            aluno_menu_turma(Matricula, Disciplina, CodTurma) ;
            write("\nDisciplina ou turma inválida\n")),
            aluno_menu(Matricula)).

turma_valida(Matricula, Disciplina, CodTurma):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    member([Disciplina, CodTurma], Dados.turmas).

aluno_menu_turma(Matricula, Disciplina, CodTurma):- 
    nl, 
    write("==== Menu do aluno "), write(Matricula), write(" na disciplina "), write(Disciplina), write(" na turma "), write(CodTurma), write("! ===="), nl,
    write("Digite uma opção: "), nl,
    write("[0] Voltar"), nl,
    write("[1] Ver notas"), nl,
    write("[2] Ver Mural"), nl,
    write("[3] Chat"), nl,
    write("[4] Avaliar professor(a)"), nl,
    write("[5] Materiais Didáticos"), nl,
    write("[6] Responder quiz"), nl,
    read(Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") -> nl;
        (escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, Op), aluno_menu_turma(Matricula, Disciplina, CodTurma))).

escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, "1"):- situacao_aluno(Disciplina, CodTurma, Matricula).
escolher_opcao_menu_turma(Matricula, Disciplina, CodTurma, _):- write("OPÇÃO INVÁLIDA").


printar_todas_turmas(Matricula):- 
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    printar_turmas(Dados.turmas).

printar_turmas([]).
printar_turmas([[Disciplina|[Turma | _]]|T]):- 
    nl, write("Disciplina: "), write(Disciplina), write(" | Turma: "), write(Turma), printar_turmas(T).
