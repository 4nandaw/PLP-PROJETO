:- module(turma, [turma_menu/2]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Disciplinas", [disciplina_menu/1]).

turma_menu(Disciplina, CodTurma):-
    string_upper(CodTurma, X),
    write("\nMENU "), write(X), write(" =====================\n"),
    write("Escolha uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Ver alunos da turma\n"),
    write("[2] Adicionar notas e ver situação de um aluno\n"),
    write("[3] Adicionar faltas\n"),
    write("[4] Ver relatório da turma\n"),
    write("[5] Ver avaliações\n"),
    write("[6] Mural da Turma\n"),
    write("[7] Chat\n"),
    write("[8] Materiais Didáticos\n"),
    write("[9] Quizzes da turma\n"),
    write("=======================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    escolher_opcao_turma_menu(Op, Disciplina, CodTurma).

escolher_opcao_turma_menu("0", Disciplina, CodTurma):- disciplina_menu(Disciplina), !.
escolher_opcao_turma_menu("2", Disciplina, CodTurma):- alocar_notas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu(_, _, _):- write("\nOPÇÃO INVÁLIDA\n").

alocar_notas(Disciplina, CodTurma):- 
    write("Digite a matrícula do aluno que você deseja alocar notas ou ver sua situação ou 'q' para sair: \n"),
    read(Matricula), convert_to_string(Matricula, M),
    ((M \== "q") -> 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        ((exists_file(Path)) -> 
            (alocar_notas_aluno(Disciplina, CodTurma, Matricula), 
            alocar_notas(Disciplina, CodTurma)) 
        ; (write("\n Aluno não está na turma \n"), alocar_notas(Disciplina, CodTurma))))
     ; nl).

alocar_notas_aluno(Disciplina, CodTurma, Matricula):-
    nl, write("Digite qual opção deseja: "), nl,
    write("[0] Voltar"), nl,
    write("[1] Alocar 1º nota"), nl,
    write("[2] Alocar 2º nota"), nl,
    write("[3] Alocar 3º nota"), nl,
    write("[4] Ver situação do aluno"), nl,
    read(Opcao),
    convert_to_string(Opcao, Op),
    ((Op == "0") ->
         nl ;
        ((opcao_valida_alocar_nota(Op)) -> 
            ((Op == "4") -> 
                situacao_aluno(Disciplina, CodTurma, Matricula) ;
                alocar_nota(Disciplina, CodTurma, Matricula, Opcao));
            write("Opção inválida")),
        alocar_notas_aluno(Disciplina, CodTurma, Matricula)).

opcao_valida_alocar_nota("1").
opcao_valida_alocar_nota("2").
opcao_valida_alocar_nota("3").
opcao_valida_alocar_nota("4").


situacao_aluno(Disciplina, CodTurma, Matricula):- 
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
    read_json(Path, Dados),
    Nota1 = Dados.nota1, Nota2 = Dados.nota2, Nota3 = Dados.nota3, Media = Dados.media, Faltas = Dados.faltas,
    write("==== SITUAÇÃO DO ALUNO "), write(Matricula), write(" ==="), nl,
    write("Nota 1: "), write(Nota1), nl,
    write("Nota 2: "), write(Nota2), nl,
    write("Nota 3: "), write(Nota2), nl,
    write("Média: "), write(Media), nl,
    write("Quantidade de faltas: "), write(Faltas), nl,
    situacao(Faltas, Media).

situacao(Faltas, _):- Faltas >= 8, nl, write("REPROVADO POR FALTA :("), nl, !.
situacao(_, Media):- Media>=7.0, nl, write("APROVADO :)"), nl, !.
situacao(_, Media):- Media>=4.0, nl, write("FINAL :|"), nl.
situacao(_, Media):- nl, write("REPROVADO :("), nl.


alocar_nota(Disciplina, CodTurma, Matricula, Opcao):-
    write("Qual a nota do aluno? "), 
    read(Nota),
    ((nota_valida(Nota)) -> 
        (concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        concat_atom(["nota", Opcao], NotaC),
        read_json(Path, Dados),
        put_dict(NotaC, Dados, Nota, Dados_gravados),
        write_json(Path, Dados_gravados),
        atualizar_media(Disciplina, CodTurma, Matricula))
    ; write("\n Nota inválida \n")).

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
