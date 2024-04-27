:- module(cadastro, [cadastroMenu/0]).
:- use_module(library(http/json)).

cadastrarAluno:-
    shell(clear),
    writeln('Digite a matricula do aluno'),
    read(Matricula), nl,
    write("Digite o nome do aluno"),
    read(Nome), nl,
    write("Digite a senha do aluno"),nl,
    read(Senha),
    validandoDados(Matricula, Nome, Senha),
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

    % Cria diretório de DB caso nao exista
    (exists_directory('./SICODI-PROLOG/db/') -> 
        ((\+ exists_directory('./SICODI-PROLOG/db/disciplinas/')) -> make_directory('./SICODI-PROLOG/db/disciplinas/'))
    ; make_directory('./SICODI-PROLOG/db/') -> make_directory('./SICODI-PROLOG/db/disciplinas/')),

    % Verifica se disciplina ja existe, cria caso contrario
    concat_atom(['./SICODI-PROLOG/db/disciplinas/', Disciplina, '.json'], Path),
    open(Path, write, Stream),
    json_write(Stream, json{matricula: Matricula, nome: Nome, disciplina: Disciplina, senha: Senha}),
    close(Stream).

cadastroMenu:-
    shell(clear),
    write("============== CADASTRO ==============="),
    write("
    [0] Sair \n
    [1] Cadastro Disciplina \n
    [2] Cadastro Aluno "),
    read(Opcao),
    escolherOpcaoCadastro(Opcao), !.

escolherOpcaoCadastro(1):- cadastrarDisciplina, !.
escolherOpcaoCadastro(2):- cadastrarAluno, !.
