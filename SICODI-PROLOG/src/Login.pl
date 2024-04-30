:- module(login, [login_menu/0]).
:- use_module(library(http/json)).
:- use_module("../utils/Utils").
:- use_module("./Disciplinas", [disciplina_menu/1]).
:- use_module("./Alunos", [aluno_menu/1]).

% LOGIN ALUNOS
login_aluno :-
    write("\nDigite a matrícula do aluno: \n"),
    read(Matricula),
    concat_atom(['../db/alunos/', Matricula, '.json'], Path),
    exists_file(Path) -> (
        write("\nDigite a senha: \n"),
        read(Senha),
        read_json(Path, Dados),
        (senha_correta(Dados.senha, Senha) -> write("\nLogin realizado com sucesso!\n"), aluno_menu(Matricula) 
        ; write("\nSenha incorreta!\n"), !)
    ) ;  write("\nEsse aluno não existe.\n").

realizar_login_aluno(Matricula, Senha) :-
    % write(Matricula),
    % write(Senha),
    concat_atom(["../db/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    senha_correta(Dados.senha, Senha),
    write("\nLogin realizado :)\n"),
    aluno_menu(Matricula), !.

senha_correta(Senha, Senha1):- convert_to_string(Senha, SenhaStr), convert_to_string(Senha1, SenhaStr).

% LOGIN DISCIPLINA
login_disciplina :- 
    write("\nDigite o nome da disciplina: \n"),
    read(Disciplina),
    concat_atom(['../db/disciplinas/', Disciplina, "/", Disciplina,'.json'], Path),
    exists_file(Path) -> (
        write("\nDigite a senha: \n"),
        read(Senha),
        read_json(Path, Dados),
        (senha_correta(Dados.senha, Senha) -> write("\nLogin realizado com sucesso!\n"), disciplina_menu(Disciplina) 
        ; write("\nSenha incorreta!\n"), !)
    ) ;  write("\nEssa disciplina não existe!\n").

login_menu:-
    write("\nLOGIN ======================\n"),
    write("[0] Voltar ao menu principal\n"),
    write("[1] Login de professor\n"),
    write("[2] Login de aluno\n"),
    write("=============================\n"),
    read(Opcao),
    escolher_opcao_login(Opcao), !.

escolher_opcao_login(1):- login_disciplina, !.
escolher_opcao_login(2):- login_aluno, !.
escolher_opcao_login(_):- write("\nENTRADA INVÁLIDA\n").