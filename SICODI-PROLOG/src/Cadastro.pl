:- module(cadastro, [cadastro_menu/0]).

:- set_prolog_flag(encoding, utf8).


:- use_module(library(http/json)).
:- use_module(library(filesex)).
% :- use_module(library(json)).
:- use_module("../utils/Utils.pl").

not_exists_file(Caminho):-
    \+ exists_file(Caminho).



gravar_dados_aluno(Matricula, Nome, Senha):-
    concat_atom(["../db/alunos/", Matricula, ".json"], Caminho),
    make_directory_path("../db/alunos"),
    not_exists_file(Caminho),
    escrever_json(Caminho, _{nome : Nome, matricula : Matricula, senha : Senha}), !.

gravar_dados_aluno(Matricula, Nome, Senha):-
    concat_atom(["../db/alunos/", Matricula, ".json"], Caminho),
    exists_file(Caminho), nl, swrite("JÁ EXISTE ALUNO COM ESSA MATRÍCULA"), nl.


cadastrar_aluno:-
    writeln('Digite a matricula do aluno'),
    read(Matricula), nl,
    write("Digite o nome do aluno"),
    read(Nome), nl,
    write("Digite a senha do aluno"),nl,
    read(Senha),
    validar_dados(Matricula, Nome, Senha).
 
 validar_dados(Matricula, Nome, Senha):- validando_dados(Matricula, Nome, Senha), gravar_dados_aluno(Matricula, Nome, Senha), !.
 validar_dados(Matricula, Nome, Senha):- write("ENTRADA INVÁLIDA!").



cadastro_menu:-
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolher_opcao_cadastro(Opcao), !.

escolher_opcao_cadastro(2):- cadastrar_aluno, !.



