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

cadastroMenu:-
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolher_opcao_cadastro(Opcao), !.

escolherOpcaoCadastro(2):- cadastrarAluno(), !.



