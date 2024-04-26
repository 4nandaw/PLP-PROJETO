:- module(cadastro, [cadastroMenu/0]).

:- set_prolog_flag(encoding, utf8).

cadastrarAluno:-
    writeln('Digite a matricula do aluno'),
    read(Matricula), nl,
    write("Digite o nome do aluno"),
    read(Nome), nl,
    write("Digite a senha do aluno"),nl,
    read(Senha),
    /*validandoDados(Matricula, Nome, Senha),*/
    write('Passou').

cadastrarDisciplina:-
    shell(clear),
    writeln('Digite a matricula do professor'),
    read(Matricula), nl,
    write("Digite o nome do professor"),
    read(Nome), nl,
    write("Digite o nome da disciplina"),nl,
    read(Disciplina),
    write("Digite a senha do professor"),nl,
    read(Senha),
    # validandoDados(Matricula, Nome, Senha) -> (
        make_directory('SICODI-PROLOG/db/disciplinas/').

    # )

cadastroMenu:-
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolherOpcaoCadastro(Opcao), !.

escolherOpcaoCadastro(1):- cadastroDisiplina(), !.
escolherOpcaoCadastro(2):- cadastrarAluno(), !.



