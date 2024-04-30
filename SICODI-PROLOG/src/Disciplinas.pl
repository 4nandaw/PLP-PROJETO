:- module(disciplina, [disciplina_menu/1]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Turmas", [turma_menu/2]).

disciplina_menu(Disciplina):-
    string_upper(Disciplina, X),
    print_purple_bold("\nMENU DE "), print_purple_bold(X), print_purple_bold(" ========\n"),
    print_purple("Digite uma opção: \n"),
    print_purple("[0] Voltar\n"),
    print_purple("[1] Criar turma\n"),
    print_purple("[2] Minhas turmas\n"),
    print_purple("[3] Adicionar aluno\n"),
    print_purple("[4] Excluir aluno\n"),
    print_purple("[5] Excluir turma\n"),
    print_purple_bold("====================\n"),
    read(Opcao),
    escolher_opcao_disciplina_menu(Opcao, Disciplina), !.

escolher_opcao_disciplina_menu(0, _):- main.
escolher_opcao_disciplina_menu(1, Disciplina):- criar_turma(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(2, Disciplina):- minhas_turmas(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(3, Disciplina):- adicionar_aluno(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(4, Disciplina):- excluir_aluno(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(5, Disciplina):- excluir_turma(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(_, _):- print_red("\nOpção inválida.\n").

criar_turma(Disciplina):-
    print_purple_bold("\nCADASTRO DE TURMA\n"),
    print_purple("\nNome da turma: \n"),
    read(NomeTurma),
    print_purple("\nCódigo da turma: \n"),
    read(CodTurma),

    concat_atom(["../db/disciplinas/", Disciplina, "/turmas"], DirectoryPath),
    make_directory_path(DirectoryPath),

    concat_atom([DirectoryPath, "/", CodTurma], CodTurmaPath),
    make_directory_path(CodTurmaPath),

    concat_atom([CodTurmaPath, "/", CodTurma, ".json"], TurmaJsonPath),
    
    (not_exists_file(TurmaJsonPath) -> 
        write_json(TurmaJsonPath, _{alunos : [], nome : NomeTurma, codigo : CodTurma}),

        make_directory(CodTurmaPath, "alunos"),
        make_directory(CodTurmaPath, "avaliacoes"),
        make_directory(CodTurmaPath, "mural"),
        make_directory(CodTurmaPath, "chats"),
        make_directory(CodTurmaPath, "quiz"),

        print_green("\nCadastro concluído!\n")
    ;   print_red("\nTurma já existente!\n")).


make_directory(CodTurmaPath, Diretorio):-
    concat_atom([CodTurmaPath, "/", Diretorio], Path),
    make_directory_path(Path).

minhas_turmas(Disciplina):-
    string_upper(Disciplina, X),
    print_purple_bold("\nTurmas de "), print_purple_bold(X), nl, nl,
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas"], Path),
    directory_files(Path, ListaDeTurmas),
    print_turmas(ListaDeTurmas),
    print_purple_bold("\n===============================================\n"),
    print_purple("Informe um codigo de turma:\n"),
    read(CodTurma),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
    (exists_file(CodTurmaPath) -> turma_menu(Disciplina, CodTurma); print_red("\nCódigo de turma inválido.\n"), minhas_turmas(Disciplina)).

print_turmas([]).
print_turmas([.|Turmas]):- print_turmas(Turmas).
print_turmas([..|Turmas]):- print_turmas(Turmas).
print_turmas([Turma|Turmas]):-
    print_purple(Turma), nl,
    print_turmas(Turmas).

adicionar_aluno(Disciplina):-
    print_purple("\nInforme o código da turma ou "), print_white_bold('q'), print_purple(" para voltar: \n"),
    read(CodTurma),
    (CodTurma \= 'q' -> 
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
        (exists_file(CodTurmaPath) -> 
            print_purple("\nInforme a matricula do aluno: \n"),
            read(Matricula),
            alocar_aluno(Matricula, Disciplina, CodTurma)
        ;    print_red("\nCódigo de turma inválido!\n"), adicionar_aluno(Disciplina))
    ;   disciplina_menu(Disciplina)).

alocar_aluno(Matricula, Disciplina, CodTurma):-
    (Matricula \= 'q' ->
        concat_atom(["../db/alunos/", Matricula, ".json"], MatriculaPath),
        (exists_file(MatriculaPath) -> 
            concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], AlunoTurmaPath),
            (not_exists_file(AlunoTurmaPath) ->
                read_json(MatriculaPath, DadosAluno),
                append([[Disciplina, CodTurma]], DadosAluno.turmas, TurmasAtualizadas),
                put_dict(turmas, DadosAluno, TurmasAtualizadas, DadosAtualizaddos),
                write_json(MatriculaPath, DadosAtualizaddos),
                write_json(AlunoTurmaPath, _{faltas : 0, media : 0, nota1 : 0, nota2 : 0, nota3 : 0}),
                print_green("\nAluno "), print_white_bold(Matricula), print_green(" adicionado!\n"),
                print_purple("\nInforme a matrícula do próximo aluno ou "), print_white_bold('q'), print_purple(" para finalizar: \n"),
                read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma)
            ;   print_red("\nAluno já adicionado!\n"),
                print_purple("\nInforme a matrícula do próximo aluno ou "), print_white_bold('q'), print_purple(" para finalizar: \n"),
                read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma))
        ;   print_red("\nMatrícula inválida!\n"),
        
                print_purple("\nInforme a matrícula do próximo aluno ou "), print_white_bold('q'), print_purple(" para finalizar: \n"),
            read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma))
    ;   print_green("\nRegistro finalizado!\n")).

excluir_aluno(Disciplina):-
    print_purple("\nInforme o código da turma ou "), print_white_bold('q'), print_purple(" para voltar: \n"),
    read(CodTurma),
    (CodTurma \= 'q' ->
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
        (exists_file(CodTurmaPath) -> 
            print_purple("\nInforme a matrícula do aluno: \n"),
            read(Matricula),
            remove_aluno(Matricula, Disciplina, CodTurma)
        ;   print_red("\nCódigo de turma inválido!\n"), excluir_aluno(Disciplina))
    ;   disciplina_menu(Disciplina)).

remove_aluno(Matricula, Disciplina, CodTurma):-
    (Matricula \= 'q' ->
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], AlunoTurmaPath),
        (exists_file(AlunoTurmaPath) -> 
            delete_file(AlunoTurmaPath),
            print_green("\nAluno "), print_white_bold(Matricula), print_green(" removido!\n"),
            print_purple("\nInforme a matrícula do próximo aluno ou "), print_white_bold('q'), print_purple(" para finalizar: \n"),
            read(NovaMatricula), remove_aluno(NovaMatricula, Disciplina, CodTurma)
        ;   print_red("\nMatrícula inválida!\n"),
            print_purple("\nInforme a matrícula do próximo aluno ou "), print_white_bold('q'), print_purple(" para finalizar: \n"),
            read(NovaMatricula), remove_aluno(NovaMatricula, Disciplina, CodTurma))
    ;   print_green("\nRegistro finalizado!\n")).

excluir_turma(Disciplina):-
    print_purple("\nInforme o codigo da turma a ser excluida: \n"),
    read(CodTurma),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma], CodTurmaPath),
    (exists_directory(CodTurmaPath) ->
        force_delete_directory(CodTurmaPath),
        print_green("\nTurma removida!\n")
    ;   print_red("\nCódigo de turma inválido!\n")).

force_delete_directory(Directory) :-
    atom_concat('rm -rf ', Directory, Command),
    shell(Command).