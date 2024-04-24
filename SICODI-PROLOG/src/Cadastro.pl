:- consult:- Utils.pl

cadastrarAluno:-
    writeln('Digite a matricula do aluno'),
    read(Matricula), nl,
    write("Digite o nome do aluno"),
    read(Nome), nl,
    write("Digite a senha do aluno"),nl,
    read(Senha),
    validandoDados(Matricula, Nome, Senha),
    write('Passou').

cadastro:-
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolherOpcaoCadastro(Opcao), !.

escolherOpcaoCadastro(2):- cadastrarAluno(), !.



