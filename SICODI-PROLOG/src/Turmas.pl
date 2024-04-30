:- module(turma, [turma_menu/2, situacao_aluno/3]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Disciplinas", [disciplina_menu/1]).

turma_menu(Disciplina, CodTurma):-
    string_upper(CodTurma, X),
    print_purple_bold("\nMENU "), print_purple_bold(X), print_purple_bold(" =====================\n"),
    print_purple("Escolha uma opção: \n"),
    print_purple("[0] Voltar\n"),
    print_purple("[1] Ver alunos da turma\n"),
    print_purple("[2] Adicionar notas e ver situação de um aluno\n"),
    print_purple("[3] Adicionar faltas\n"),
    print_purple("[4] Ver relatório da turma\n"),
    print_purple("[5] Ver avaliações\n"),
    print_purple("[6] Mural da Turma\n"),
    print_purple("[7] Chat\n"),
    print_purple("[8] Materiais Didáticos\n"),
    print_purple("[9] Quizzes da turma\n"),
    print_purple_bold("=======================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    escolher_opcao_turma_menu(Op, Disciplina, CodTurma).

escolher_opcao_turma_menu("0", Disciplina, CodTurma):- disciplina_menu(Disciplina), !.
escolher_opcao_turma_menu("2", Disciplina, CodTurma):- alocar_notas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("3", Disciplina, CodTurma):- alocar_faltas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu(_, Disciplina, CodTurma):- print_red("\nOpção inválida.\n"), turma_menu(Disciplina, CodTurma).

alocar_notas(Disciplina, CodTurma):- 
    print_purple("\nDigite a matrícula do aluno que deseja alocar notas/ver situação ou "), print_white_bold('q'), print_purple(" para sair: \n"),
    read(Matricula), convert_to_string(Matricula, M),
    ((M \== "q") -> 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        ((exists_file(Path)) -> 
            (alocar_notas_aluno(Disciplina, CodTurma, Matricula), 
            alocar_notas(Disciplina, CodTurma)) 
        ; (print_red("\nAluno não está na turma.\n"), alocar_notas(Disciplina, CodTurma))))
     ; nl).

alocar_notas_aluno(Disciplina, CodTurma, Matricula):-
    nl, print_purple_bold("Digite qual opção deseja: "), nl,
    print_purple("[0] Voltar"), nl,
    print_purple("[1] Alocar 1º nota"), nl,
    print_purple("[2] Alocar 2º nota"), nl,
    print_purple("[3] Alocar 3º nota"), nl,
    print_purple("[4] Ver situação do aluno"), nl,
    read(Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") ->
         nl ;
        ((opcao_valida_alocar_nota(Op)) -> 
            ((Op == "4") -> 
                situacao_aluno(Disciplina, CodTurma, Matricula) ;
                alocar_nota(Disciplina, CodTurma, Matricula, Opcao));
            print_red("\nOpção inválida.\n")),
        alocar_notas_aluno(Disciplina, CodTurma, Matricula)).

opcao_valida_alocar_nota("1").
opcao_valida_alocar_nota("2").
opcao_valida_alocar_nota("3").
opcao_valida_alocar_nota("4").


situacao_aluno(Disciplina, CodTurma, Matricula):- 
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    Nota1 = Dados.nota1, Nota2 = Dados.nota2, Nota3 = Dados.nota3, Media = Dados.media, Faltas = Dados.faltas,
    write("\n"),
    print_purple_bold("==== SITUAÇÃO DO ALUNO "), print_white_bold(Matricula), print_purple_bold(" ==="), nl,
    print_purple("Nota 1: "), print_white_bold(Nota1), nl,
    print_purple("Nota 2: "), print_white_bold(Nota2), nl,
    print_purple("Nota 3: "), print_white_bold(Nota2), nl,
    print_purple("Média: "), print_white_bold(Media), nl,
    print_purple("Quantidade de faltas: "), print_white_bold(Faltas), nl,
    situacao(Faltas, Media).

situacao(Faltas, _):- Faltas >= 8, nl, print_red("REPROVADO POR FALTA :("), nl, !.
situacao(_, Media):- Media>=7.0, nl, print_green("APROVADO :)"), nl, !.
situacao(_, Media):- Media>=4.0, nl, print_yellow("FINAL :|"), nl.
situacao(_, Media):- nl, print_red("REPROVADO :("), nl.


alocar_nota(Disciplina, CodTurma, Matricula, Opcao):-
    print_purple("\nQual a nota do aluno?\n"), 
    read(Nota),
    ((nota_valida(Nota)) -> 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        concat_atom(["nota", Opcao], NotaC),
        read_json(Path, Dados),
        put_dict(NotaC, Dados, Nota, Dados_gravados),
        write_json(Path, Dados_gravados),
        atualizar_media(Disciplina, CodTurma, Matricula))
    ; print_red("\nNota inválida.\n")).

nota_valida(Nota):- number(Nota), Nota=<10.0, Nota>=0.

atualizar_media(Disciplina, CodTurma, Matricula):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    calcular_media(Dados, Media),
    put_dict(media, Dados, Media, Dados_gravados),
    write_json(Path, Dados_gravados).

    
calcular_media(Dados, Media):- 
    M is (Dados.nota1 + Dados.nota2 + Dados.nota3)/3,
    format(atom(MediaFormatada), '~2f', M),
    atom_number(MediaFormatada, Media).

alocar_faltas(Disciplina, CodTurma):- 
    nl, print_purple("\nDigite a matrícula do aluno que deseja alocar faltas ou "), print_white_bold('q'), print_purple(" para sair: \n"),
    read(Matricula),
    convert_to_string(Matricula, M),
    ((M == "q") -> nl ;
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        ((not_exists_file(Path))-> (nl, print_red("\nAluno não está na turma.\n"), nl) ;
            read_json(Path, Dados),
            Faltas is (Dados.faltas + 1),
            put_dict(faltas, Dados, Faltas, DadosGravados),
            write_json(Path, DadosGravados),
            nl, print_green("\nFalta adicionada!\n")), nl,
            alocar_faltas(Disciplina, CodTurma)).