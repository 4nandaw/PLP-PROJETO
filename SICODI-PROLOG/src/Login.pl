:- module(login, [loginMenu/0]).
:- use_module(library(http/json)).

loginDisciplina :- 
    shell(clear),
    writeln('Digite o nome da disciplina'),
    read(Disciplina), nl,

    concat_atom(['./SICODI-PROLOG/db/disciplinas/', Disciplina, '.json'], Path),
    exists_file(Path) -> (
        write("Digite a senha"),
        read(Senha),

        open(Path, read, Stream),
        json_read_dict(Stream, Dict),
        ((Dict.senha =:= Senha) -> write('Login realizado!!!') ; write('Senha incorreta \n')),
        close(Stream)
    ) ;  write('Disciplina não existe').

loginMenu:-
    shell(clear),
    write("============== LOGIN ==============="),
    write("
    [0] Sair \n
    [1] Login Disciplina \n
    [2] Login Aluno "),
    read(Opcao),
    escolherOpcaoLogin(Opcao), !.

escolherOpcaoLogin(1) :- loginDisciplina.