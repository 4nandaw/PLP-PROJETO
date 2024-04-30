:- module(disciplina, [disciplina_menu/1]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Turmas", [turma_menu/2]).
:- use_module("../utils/Utils", [dado_valido/1]). 

disciplina_menu(Disciplina):-
    string_upper(Disciplina, X),
    write("\nMENU DE "), write(X), write(" ========\n"),
    write("Digite uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Criar turma\n"),
    write("[2] Minhas turmas\n"),
    write("[3] Adicionar aluno\n"),
    write("[4] Excluir aluno\n"),
    write("[5] Excluir turma\n"),
    write("====================\n"),
    read(Opcao),
    escolher_opcao_disciplina_menu(Opcao, Disciplina), !.

escolher_opcao_disciplina_menu(0, _):- main.
escolher_opcao_disciplina_menu(1, Disciplina):- criar_turma(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(2, Disciplina):- minhas_turmas(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(3, Disciplina):- adicionar_aluno(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(4, Disciplina):- excluir_aluno(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(5, Disciplina):- excluir_turma(Disciplina), disciplina_menu(Disciplina).
escolher_opcao_disciplina_menu(_, _):- write("\nOPÇÃO INVÁLIDA\n").

criar_turma(Disciplina):-
    write("\nCADASTRO DE TURMA\n\n"),
    write("Nome da turma: \n"),
    read(NomeTurma), nl,
    write("Código da turma: \n"),
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

        write("\nCadastro concluído!\n")
    ;   write("\nTurma já exitente!\n")).

make_directory(CodTurmaPath, Diretorio):-
    concat_atom([CodTurmaPath, "/", Diretorio], Path),
    make_directory_path(Path).

minhas_turmas(Disciplina):-
    string_upper(Disciplina, X),
    write("\nTurmas de "), write(X), nl, nl,
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas"], Path),
    directory_files(Path, ListaDeTurmas),
    print_turmas(ListaDeTurmas),
    write("\n===============================================\n"),
    write("Informe um codigo de turma:\n"),
    read(CodTurma),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
    (exists_file(CodTurmaPath) -> turma_menu(Disciplina, CodTurma); write("\nCódigo de turma inválido!\n"), minhas_turmas(Disciplina)).

print_turmas([]).
print_turmas([.|Turmas]):- print_turmas(Turmas).
print_turmas([..|Turmas]):- print_turmas(Turmas).
print_turmas([Turma|Turmas]):-
    write(Turma), nl,
    print_turmas(Turmas).

adicionar_aluno(Disciplina):-
    write("\nInforme o código da turma ou 'q' para voltar: \n"),
    read(CodTurma),
    (CodTurma \= 'q' -> 
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
        (exists_file(CodTurmaPath) -> 
            write("\nInforme a matricula do aluno: \n"),
            read(Matricula),
            alocar_aluno(Matricula, Disciplina, CodTurma)
        ;    write("\nCódigo de turma inválido!\n"), adicionar_aluno(Disciplina))
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
                write("\nAluno "), write(Matricula), write(" adicionado!\n"),
                write("\nInforme a matrícula do próximo aluno ou 'q' para finalizar: \n"),
                read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma)
            ;   write("\nAluno já adicionado!\n"),
                write("\nInforme a matrícula do próximo aluno ou 'q' para finalizar: \n"),
                read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma))
        ;   write("\nMatrícula inválida!\n"),
            write("\nInforme a matrícula do próximo aluno ou 'q' para finalizar: \n"),
            read(NovaMatricula), alocar_aluno(NovaMatricula, Disciplina, CodTurma))
    ;   write("\nRegistro finalizado!\n")).

excluir_aluno(Disciplina):-
    write("\nInforme o código da turma ou 'q' para voltar: \n"),
    read(CodTurma),
    (CodTurma \= 'q' ->
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/", CodTurma, ".json"], CodTurmaPath),
        (exists_file(CodTurmaPath) -> 
            write("\nInforme a matrícula do aluno: \n"),
            read(Matricula),
            remove_aluno(Matricula, Disciplina, CodTurma)
        ;   write("\nCódigo de turma inválido!\n"), excluir_aluno(Disciplina))
    ;   disciplina_menu(Disciplina)).

remove_aluno(Matricula, Disciplina, CodTurma):-
    (Matricula \= 'q' ->
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], AlunoTurmaPath),
        (exists_file(AlunoTurmaPath) -> 
            delete_file(AlunoTurmaPath),
            write("\nAluno "), write(Matricula), write(" removido!\n"),
            write("\nInforme a matrícula do próximo aluno ou 'q' para finalizar: \n"),
            read(NovaMatricula), remove_aluno(NovaMatricula, Disciplina, CodTurma)
        ;   write("\nMatrícula inválida!\n"),
            write("\nInforme a matrícula do próximo aluno ou 'q' para finalizar: \n"),
            read(NovaMatricula), remove_aluno(NovaMatricula, Disciplina, CodTurma))
    ;   write("\nRegistro finalizado!\n")).

excluir_turma(Disciplina):-
    write("\nInforme o codigo da turma a ser excluida: \n"),
    read(CodTurma),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma], CodTurmaPath),
    (exists_directory(CodTurmaPath) ->
        force_delete_directory(CodTurmaPath),
        write("\nTurma removida!\n")
    ;   write("\nCódigo de turma inválido!\n")).

force_delete_directory(Directory) :-
    atom_concat('rm -rf ', Directory, Command),
    shell(Command).