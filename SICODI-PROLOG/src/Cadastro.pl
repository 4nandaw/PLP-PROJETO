:- module(cadastro, [cadastro_menu/0]).

:- set_prolog_flag(encoding, utf8).

%:- use_module(library(http/json)).
:- use_module(library(filesex)).
:- use_module("../utils/Utils").
:- use_module(library(readutil)).



% MENU
cadastro_menu:-
    print_yellow_bold("\nCADASTRO =====================\n"),
    write("[0] Voltar\n"),
    write("[1] Cadastro de professor\n"),
    write("[2] Cadastro de aluno\n"),
    print_yellow_bold("==============================\n"),
    read_line_to_string(user_input, Opcao),
    escolher_opcao_cadastro(Opcao).

escolher_opcao_cadastro("0"):- main, !.
escolher_opcao_cadastro("1"):- cadastrar_disciplina, !.
escolher_opcao_cadastro("2"):- cadastrar_aluno, !.

% DISCIPLINAS

% RECEBE OS DADOS
cadastrar_disciplina:-
    print_yellow("\nDigite a matricula do professor: \n"),
    read_line_to_string(user_input, Matricula),
    print_yellow("\nDigite o nome do professor: \n"),
    read_line_to_string(user_input, Nome),
    print_yellow("\nDigite o nome da disciplina: \n"),
    read_line_to_string(user_input, Disciplina),
    print_yellow("\nDigite a senha do professor: \n"),
    read_line_to_string(user_input, Senha),
    ((Matricula \= "", Nome \= "", Disciplina \= "", Senha \= "") -> 
    validar_dados_disciplina(Matricula, Nome, Disciplina, Senha);
    print_red("\nEntrada inválida. Tente novamente.\n")).

% FUNCAO PARA VALIDAR OS DADOS RECEBIDOS
% ESSA PRIMEIRA AINDA IRÁ TER UMA FUNÇÃO NO UTILS QUE SERÁ CHAMADA AQUI ANTES DE gravar_dados_disciplina
 validar_dados_disciplina(Matricula, Nome, Disciplina, Senha):- gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha), !.
 validar_dados_disciplina(_, _, _, _):- print_red("\nEntrada inválida. Tente novamente.\n").


% SALVA NO JSON
gravar_dados_disciplina(Matricula, Nome, Disciplina, Senha):-
    % Cria diretório de DB caso nao exista
    make_directory_path("../db/disciplinas"),
    concat_atom(["../db/disciplinas/", Disciplina, "/"], DisciplinaPath),
    make_directory_path(DisciplinaPath),
    concat_atom([DisciplinaPath, Disciplina, ".json"], Path),
    not_exists_file(Path),
    write_json(Path, _{nome : Nome, matricula : Matricula, disciplina : Disciplina, senha : Senha}),
    print_green("\nCadastro concluído!\n"), !.

% NOME DA DISCIPLINA JÁ EXISTE
gravar_dados_disciplina(_, _, Disciplina, _):-
    concat_atom(["../db/disciplinas/", Disciplina, ".json"], Path),
    exists_file(Path), nl, print_red("\nJá existe uma disciplina com esse nome.\n"), nl.

% ALUNOS

% RECEBE OS DADOS
cadastrar_aluno:-
    print_yellow("\nDigite a matricula do aluno:\n"),
    read_line_to_string(user_input, Matricula),
    print_yellow("\nDigite o nome do aluno: \n"),
    read_line_to_string(user_input, Nome),
    print_yellow("\nDigite a senha do aluno: \n"),
    read_line_to_string(user_input, Senha),
    ((Matricula \= ""; Nome \= ""; Senha \= "") ->  validar_dados(Matricula, Nome, Senha);
    print_red("\nEntrada inválida. Tente novamente.\n")).

% FUNÇÃO QUE CHAMA A FUNÇÃO DO UTILS PARA VALIDAR OS DADOS
 validar_dados(Matricula, Nome, Senha):- gravar_dados_aluno(Matricula, Nome, Senha), !.
 validar_dados(_, _, _):- print_red("\nEntrada inválida. Tente novamente.\n").


% SALVA NO ARQUIVO JSON
gravar_dados_aluno(Matricula, Nome, Senha):-
    make_directory_path("../db/alunos"),
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    not_exists_file(Path),
    write_json(Path, _{nome : Nome, matricula : Matricula, senha : Senha, turmas : []}), 
    print_green("\nCadastro concluído!\n"), !.

% MATRÍCULA JÁ EXISTE
gravar_dados_aluno(Matricula, _, _):-
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    exists_file(Path), nl, print_red("\nJá existe um aluno com esta matrícula.\n"), nl.