:- module(cadastro, [cadastro_menu/0]).

:- set_prolog_flag(encoding, utf8).

%:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(json)).
:- use_module("../utils/Utils").

% DISCIPLINAS 

% RECEBE OS DADOS
cadastrar_disciplina:-
    % shell(clear) Essa linha só irá funcionar em Mac ou linux, no windows essa função n vai pegar
    write("Digite a matricula do professor: \n"),
    read(Matricula),
    write("Digite o nome do professor: \n"),
    read(Nome),
    write("Digite o nome da disciplina: \n"),
    read(Disciplina),
    write("Digite a senha do professor: \n"),
    read(Senha),
    validar_dados_disciplina(Matricula, Nome, Disciplina, Senha).

% FUNCAO PARA VALIDAR OS DADOS RECEBIDOS
% ESSA PRIMEIRA AINDA IRÁ TER UMA FUNÇÃO NO UTILS QUE SERÁ CHAMADA AQUI ANTES DE gravar_dados_disciplina
 validar_dados_disciplina(Matricula, Nome, Disciplina, Senha):- gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha), !.
 validar_dados_disciplina(Matricula, Nome, Disciplina, Senha):- write("ENTRADA INVÁLIDA!").


% SALVA NO JSON
gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha):-
    % Cria diretório de DB caso nao exista
    make_directory_path("../db/disciplinas"),
    concat_atom(["../db/disciplinas/", Disciplina, "/"], DisciplinaPath),
    make_directory_path(DisciplinaPath),
    concat_atom([DisciplinaPath, Disciplina, ".json"], Path),
    not_exists_file(Path),
    write_json(Path, _{nome : Nome, matricula : Matricula, disciplina : Disciplina, senha : Senha}),
    write("\nCadastro concluído!\n"), !.

% MATRÍCULA JÁ EXISTE
gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha):-
    concat_atom(["../db/disciplinas/", Disciplina, ".json"], Path),
    exists_file(Path), nl, write("JÁ EXISTE DISCIPLINA COM ESSE NOME!"), nl.


% ALUNOS

% RECEBE OS DADOS
cadastrar_aluno:-
    write("Digite a matricula do aluno: \n"),
    read(Matricula),
    write("Digite o nome do aluno: \n"),
    read(Nome),
    write("Digite a senha do aluno: \n"),
    read(Senha),
    validar_dados(Matricula, Nome, Senha).

% FUNÇÃO QUE CHAMA A FUNÇÃO DO UTILS PARA VALIDAR OS DADOS
 validar_dados(Matricula, Nome, Senha):- gravar_dados_aluno(Matricula, Nome, Senha), !.
 validar_dados(Matricula, Nome, Senha):- write("ENTRADA INVÁLIDA!").


% SALVA NO ARQUIVO JSON
gravar_dados_aluno(Matricula, Nome, Senha):-
    make_directory_path("../db/alunos"),
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    not_exists_file(Path),
    write_json(Path, _{nome : Nome, matricula : Matricula, senha : Senha}), 
    write("\nCadastro concluído!\n"), !.

% MATRÍCULA JÁ EXISTE
gravar_dados_aluno(Matricula, Nome, Senha):-
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    exists_file(Path), nl, write("JÁ EXISTE ALUNO COM ESSA MATRÍCULA!"), nl.


% MENU
cadastro_menu:-
    write("\nCADASTRO =====================\n"),
    write("[0] Sair\n"),
    write("[1] Cadastro de professor\n"),
    write("[2] Cadastro de aluno\n"),
    write("==============================\n"),
    read(Opcao),
    escolher_opcao_cadastro(Opcao), !.

escolher_opcao_cadastro(0):- main, !.
escolher_opcao_cadastro(1):- cadastrar_disciplina, !.
escolher_opcao_cadastro(2):- cadastrar_aluno, !.