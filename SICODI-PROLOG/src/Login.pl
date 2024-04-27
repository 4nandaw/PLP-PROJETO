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
        ((Dict.senha =:= Senha) -> write('Login realizado com sucesso!\n') ; write('Senha incorreta!\n')),
        close(Stream),
        disciplina_menu(Disciplina)
    ) ;  write('Disciplina não existe').
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
escolher_opcao_login(_):- nl, write("ENTRADA INVÁLIDA"), nl.

disciplina_menu(Disciplina):-
    string_upper(Disciplina, X),
    write("\nMENU DE "), write(X), write(" ========\n"),
    write("Digite uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Minhas turmas\n"),
    write("[2] Criar turma\n"),
    write("[3] Adicionar aluno\n"),
    write("[4] Excluir aluno\n"),
    write("[5] Excluir turma\n"),
    write("====================\n"),
    read(Opcao),
    escolher_opcao_disciplina_menu(Opcao), !.

escolher_opcao_disciplina_menu(0):- main, !.
escolher_opcao_disciplina_menu(1):- write("Em construção").
escolher_opcao_disciplina_menu(2):- write("Em construção").
escolher_opcao_disciplina_menu(3):- write("Em construção").
escolher_opcao_disciplina_menu(4):- write("Em construção").
escolher_opcao_disciplina_menu(5):- write("Em construção").
escolher_opcao_disciplina_menu(_):- nl, write("ENTRADA INVÁLIDA"), nl.