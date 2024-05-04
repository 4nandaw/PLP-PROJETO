:- module(login, [login_menu/0]).
:- use_module(library(http/json)).
:- use_module("../utils/Utils").
:- use_module("./Disciplinas", [disciplina_menu/1]).
:- use_module("./Alunos", [aluno_menu/1]).
:- use_module(library(readutil)).
:- set_prolog_flag(encoding, utf8).

% LOGIN ALUNOS
login_aluno :-
    print_yellow("\nDigite a matrícula do aluno: \n"),
    read_line_to_string(user_input, Matricula),
    concat_atom(['../db/alunos/', Matricula, '.json'], Path),
    exists_file(Path) -> (
        print_yellow("\nDigite a senha: \n"),
        read_line_to_string(user_input, Senha),
        read_json(Path, Dados),
        (senha_correta(Dados.senha, Senha) -> print_green("\nLogin realizado com sucesso!\n"), aluno_menu(Matricula) 
        ; print_red("\nSenha incorreta!\n"), !)
    ) ;  print_red("\nEsse aluno não existe.\n").

realizar_login_aluno(Matricula, Senha) :-
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    senha_correta(Dados.senha, Senha),
    print_green("\nLogin realizado :)\n"),
    aluno_menu(Matricula), !.

senha_correta(Senha, Senha1):- convert_to_string(Senha, SenhaStr), convert_to_string(Senha1, SenhaStr).

% LOGIN DISCIPLINA
login_disciplina :- 
    print_yellow("\nDigite o nome da disciplina: \n"),
    read_line_to_string(user_input, Disciplina),
    concat_atom(['../db/disciplinas/', Disciplina, "/", Disciplina,'.json'], Path),
    exists_file(Path) -> (
        print_yellow("\nDigite a senha: \n"),
        read_line_to_string(user_input, Senha),
        read_json(Path, Dados),
        (senha_correta(Dados.senha, Senha) -> print_green("\nLogin realizado com sucesso!\n"), disciplina_menu(Disciplina) 
        ; print_red("\nSenha incorreta!\n"), !)
    ) ;  print_red("\nEssa disciplina não existe!\n").

login_menu:-
    print_yellow_bold("\nLOGIN ======================\n"),
    print_yellow_bold("Digite uma opção: \n"),
    write("[0] Voltar ao menu principal\n"),
    write("[1] Login de professor\n"),
    write("[2] Login de aluno\n"),
    print_yellow_bold("=============================\n"),
    read_line_to_string(user_input, Opcao),
    escolher_opcao_login(Opcao), !.

escolher_opcao_login("1"):- login_disciplina, !.
escolher_opcao_login("2"):- login_aluno, !.
escolher_opcao_login(_):- print_red("\nEntrada inválida.\n").