:- module(turma, [turma_menu/2]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Disciplinas", [disciplina_menu/1]).

turma_menu(Disciplina, CodTurma):-
    string_upper(CodTurma, X),
    write("\nMENU "), write(X), write(" =====================\n"),
    write("Escolha uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Ver alunos da turma\n"),
    write("[2] Adicionar notas e ver situação de um aluno\n"),
    write("[3] Adicionar faltas\n"),
    write("[4] Ver relatório da turma\n"),
    write("[5] Ver avaliações\n"),
    write("[6] Mural da Turma\n"),
    write("[7] Chat\n"),
    write("[8] Materiais Didáticos\n"),
    write("[9] Quizzes da turma\n"),
    write("=======================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    escolher_opcao_turma_menu(Op, Disciplina, CodTurma).

alocar_notas(Disciplina, CodTurma):- 
    write("Digite a matrícula do aluno que você deseja alocar notas ou ver sua situação ou 'q' para sair: \n"),
    read(Matricula), convert_to_string(Matricula, M),
    ((M \== "q") -> 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        ((exists_file(Path)) -> 
            (alocar_notas_aluno(Disciplina, CodTurma, Matricula), 
            alocar_notas(Disciplina, CodTurma)) 
        ; (write("\n Aluno não está na turma \n"), alocar_notas(Disciplina, CodTurma))))
     ; nl).

alocar_notas_aluno(Disciplina, CodTurma, Matricula):-
    write("\n Digite qual opção deseja: "), nl,
    write("[0] Voltar"), nl,
    write("[1] Alocar 1º nota"), nl,
    write("[2] Alocar 2º nota"), nl,
    write("[3] Alocar 3º nota"), nl,
    read(Opcao),
    convert_to_string(Opcao, Op).
    % (opcao_valida(Op)) -> alocar_nota(Disciplina, CodTurma, Matricula, Opcao) ; write("Opção inválida"),
    % escolher_opcao_alocar_notas_aluno(Disciplina, CodTurma, Matricula).

alocar_nota(Disciplina, CodTurma, Matricula, Opcao):-
    write("Em andamento...").


opcao_valida("1").
opcao_valida("2").
opcao_valida("3").



solicitar__e_alocar_aluno:- write()

escolher_opcao_turma_menu("0", Disciplina, CodTurma):- disciplina_menu(Disciplina), !.
escolher_opcao_turma_menu("2", Disciplina, CodTurma):- alocar_notas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu(_, _, _):- write("\nOPÇÃO INVÁLIDA\n").