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
    escolher_opcao_turma_menu(Opcao, Disciplina).

escolher_opcao_turma_menu(0, Disciplina):- disciplina_menu(Disciplina).
escolher_opcao_turma_menu(_, _):- write("\nOPÇÃO INVÁLIDA\n").