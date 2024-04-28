:- module(login, [login_menu/0]).
:- use_module(library(http/json)).
:- use_module("../utils/Utils").
:- use_module("./Disciplinas", [disciplina_menu/1]).

% LOGIN ALUNOS
login_aluno :-
    write("\nDigite a matrícula do aluno: \n"),
    read(Matricula),
    write("\nDigite a senha: \n"),
    read(Senha),
    validar_dados(Matricula, Senha).

% Terá uma função em utils antes para validar as entradas
validar_dados(Matricula, Senha) :- realizar_login_aluno(Matricula, Senha), !.
validar_dados(Matricula, Senha) :- nl, write("DIGITE APENAS ENTRADAS VÁLIDAS"), nl.

realizar_login_aluno(Matricula, Senha) :- 
    concat_atom(['../db/alunos/', Matricula, '.json'], Path),
    not_exists_file(Path),
    nl, write("NÃO EXISTE ALUNO COM ESSA MATRÍCULA!"), nl, !.

realizar_login_aluno(Matricula, Senha) :-
    concat_atom(['../db/alunos/', Matricula, '.json'], Path),
    read_json(Path, Dados),
    senha_correta(Dados.senha, Senha),
    write("\nLogin realizado :)\n"), !.

realizar_login_aluno(_, _) :-
    nl, write("Senha incorreta"), nl.

senha_correta(Senha1, Senha2):- Senha1 == Senha2.


% LOGIN DISCIPLINA
login_disciplina :- 
    write("\nDigite o nome da disciplina: \n"),
    read(Disciplina),
    concat_atom(['../db/disciplinas/', Disciplina, "/", Disciplina,'.json'], Path),
    exists_file(Path) -> (
        write("\nDigite a senha: \n"),
        read(Senha),
        open(Path, read, Stream),
        json_read_dict(Stream, Dict),
        ((Dict.senha =:= Senha) -> write('Login realizado com sucesso!\n') ; write('Senha incorreta!\n')),
        close(Stream),
        disciplina_menu(Disciplina)
    ) ;  write("\nEssa disciplina não existe!\n").
/* % shell(clear) */

login_menu:-
    write("\nLOGIN ======================\n"),
    write("[0] Voltar ao menu principal\n"),
    write("[1] Login de professor\n"),
    write("[2] Login de aluno\n"),
    write("=============================\n"),
    read(Opcao),
    escolher_opcao_login(Opcao), !.
    /*% shell(clear) Essa linha só irá funcionar em Mac ou linux/windows essa função n vai pegar*/

escolher_opcao_login(1):- login_disciplina, !.
escolher_opcao_login(2):- login_aluno, !.
escolher_opcao_login(_):- write("\nENTRADA INVÁLIDA\n").