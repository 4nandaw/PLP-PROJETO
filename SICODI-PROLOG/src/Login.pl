:- module(login, [login_menu/0]).
:- use_module(library(http/json)).
:- use_module("../utils/Utils").


% LOGIN ALUNOS

login_aluno :-
    write("Digite a matrícula do aluno: "), nl,
    read(Matricula), nl,
    write("Digite a senha"),
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
    write("Login realizado :)"), !.

realizar_login_aluno(_, _) :-
    nl, write("Senha incorreta"), nl.

senha_correta(Senha1, Senha2):- Senha1 == Senha2.


% LOGIN DISCIPLINA
login_disciplina :- 
    write('Digite o nome da disciplina'),
    read(Disciplina), nl,
    concat_atom(['../db/disciplinas/', Disciplina, '.json'], Path),
    exists_file(Path) -> (
        write("Digite a senha"),
        read(Senha),

        open(Path, read, Stream),
        json_read_dict(Stream, Dict),
        ((Dict.senha =:= Senha) -> write('Login realizado!!!') ; write('Senha incorreta! \n')),
        close(Stream)
    ) ;  write('Disciplina não existe').
/* % shell(clear) */


login_menu:-
    write("============== LOGIN ==============="),
    write("
    [0] Sair \n
    [1] Login Disciplina \n
    [2] Login Aluno "),
    read(Opcao),
    escolher_opcao_login(Opcao), !.
    /*% shell(clear) Essa linha só irá funcionar em Mac ou linux/windows essa função n vai pegar*/

escolher_opcao_login(1):- login_disciplina, !.
escolher_opcao_login(2):- login_aluno, !.
escolher_opcao_login(_):- nl, write("ENTRADA INVÁLIDA"), nl.