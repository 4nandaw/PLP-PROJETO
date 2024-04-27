:- module(cadastro, [cadastro_menu/0]).

:- set_prolog_flag(encoding, utf8).


%:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module(library(json)).
:- use_module("../utils/Utils").

% DISCIPLINAS 

% RECEBE OS DADOS
cadastrar_disciplina:-
    %shell(clear) Essa linha só irá funcionar em Mac ou linux, no windows essa função n vai pegar
    write('Digite a matricula do professor'),
    read(Matricula), nl,
    write("Digite o nome do professor"),
    read(Nome), nl,
    write("Digite o nome da disciplina"),nl,
    read(Disciplina),
    write("Digite a senha do professor"),nl,
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
    concat_atom(["../db/disciplinas/", Disciplina, ".json"], Path),
    not_exists_file(Path),
    write_json(Path, _{nome : Nome, matricula : Matricula, disciplina : Disciplina, senha : Senha}), !.

% MATRÍCULA JÁ EXISTE
gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha):-
    concat_atom(["../db/disciplinas/", Disciplina, ".json"], Path),
    exists_file(Path), nl, write("JÁ EXISTE DISCIPLINA COM ESSE NOME!"), nl.


% ALUNOS

% RECEBE OS DADOS
cadastrar_aluno:-
    writeln('Digite a matricula do aluno'),
    read(Matricula), nl,
    write("Digite o nome do aluno"),
    read(Nome), nl,
    write("Digite a senha do aluno"),nl,
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
    write_json(Path, _{nome : Nome, matricula : Matricula, senha : Senha}), !.

% MATRÍCULA JÁ EXISTE
gravar_dados_aluno(Matricula, Nome, Senha):-
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    exists_file(Path), nl, write("JÁ EXISTE ALUNO COM ESSA MATRÍCULA!"), nl.


% MENU
cadastro_menu:-
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolher_opcao_cadastro(Opcao), !.

escolher_opcao_cadastro(1):- cadastrar_disciplina, !.
escolher_opcao_cadastro(2):- cadastrar_aluno, !.

