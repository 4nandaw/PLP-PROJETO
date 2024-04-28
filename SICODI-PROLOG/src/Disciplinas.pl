:- module(disciplina, [disciplina_menu/1]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Turmas", [turma_menu/2]).

disciplina_menu(Disciplina):-
    string_upper(Disciplina, X),
    write("\nMENU DE "), write(X), write(" ========\n"),
    write("Digite uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Criar turma\n"),
    write("[2] Minhas turmas\n"),
    write("[3] Adicionar aluno\n"),
    write("[4] Excluir aluno\n"),
    write("[5] Excluir turma\n"),
    write("====================\n"),
    read(Opcao),
    escolher_opcao_disciplina_menu(Opcao, Disciplina), !.

escolher_opcao_disciplina_menu(0, _):- main.
escolher_opcao_disciplina_menu(1, Disciplina):- criar_turma(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(2, Disciplina):- minhas_turmas(Disciplina), nl, disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(3, _):- write("Em construção").
escolher_opcao_disciplina_menu(4, _):- write("Em construção").
escolher_opcao_disciplina_menu(5, _):- write("Em construção").
escolher_opcao_disciplina_menu(_, _):- write("\nOPÇÃO INVÁLIDA\n").

criar_turma(Disciplina):-
    write("\nCADASTRO DE TURMA\n\n"),
    write("Nome da turma: \n"),
    read(NomeTurma),
    write("Código da turma: \n"),
    read(CodTurma),
    % validar dados / verificar se já existe?

    concat_atom(["../db/disciplinas/", Disciplina, "/turmas"], DirectoryPath),
    make_directory_path(DirectoryPath),

    concat_atom([DirectoryPath, "/", CodTurma], CodTurmaPath),
    make_directory_path(CodTurmaPath),

    make_directory(CodTurmaPath, "alunos"),

    make_directory(CodTurmaPath, "avaliacoes"),

    make_directory(CodTurmaPath, "mural"),

    make_directory(CodTurmaPath, "chats"),

    make_directory(CodTurmaPath, "quiz"),

    concat_atom([CodTurmaPath, "/", CodTurma, ".json"], TurmaJsonPath),
    not_exists_file(TurmaJsonPath),
    write_json(TurmaJsonPath, _{alunos : [], nome : NomeTurma, codigo : CodTurma}),
    write("\nCadastro concluído!\n").

make_directory(CodTurmaPath, Diretorio):-
    concat_atom([CodTurmaPath, "/", Diretorio], Path),
    make_directory_path(Path).

minhas_turmas(Disciplina):-
    string_upper(Disciplina, X),
    write("\nTurmas de "), write(X), nl,

    write("\n===============================================\n"),
    write("Informe um codigo de turma:\n"),
    read(CodTurma),
    % validar
    turma_menu(Disciplina, CodTurma).