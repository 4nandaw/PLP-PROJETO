:- module(turma, [turma_menu/2, situacao_aluno/3]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Disciplinas", [disciplina_menu/1]).
:- use_module("../utils/Utils", [remove_pontos/2]).

turma_menu(Disciplina, CodTurma):-
    string_upper(CodTurma, X),
    print_purple_bold("\nMENU "), print_purple_bold(X), print_purple_bold(" =====================\n"),
    print_purple("Escolha uma opção: \n"),
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
    print_purple_bold("=======================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    escolher_opcao_turma_menu(Op, Disciplina, CodTurma).

escolher_opcao_turma_menu("0", Disciplina, CodTurma):- disciplina_menu(Disciplina), !.
escolher_opcao_turma_menu("1", Disciplina, CodTurma):- ver_alunos(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("2", Disciplina, CodTurma):- alocar_notas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("3", Disciplina, CodTurma):- alocar_faltas(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("4", Disciplina, CodTurma):- ver_relatorio(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("5", Disciplina, CodTurma):- ver_avaliacoes(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("8", Disciplina, CodTurma):- materiais_didaticos_menu(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu(_, Disciplina, CodTurma):- print_red("\nOpção inválida.\n"), turma_menu(Disciplina, CodTurma).

ver_alunos(Disciplina, CodTurma):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos"], AlunosTurmaPath),
    concat_atom(["../db/alunos"], AlunosPath),
    directory_files(AlunosTurmaPath, Lista),
    remove_pontos(Lista, AlunosTurma),
    length(AlunosTurma, Length),
    print_purple_bold("\nALUNOS ================================\n\n"),
    (Length > 0 ->
        print_alunos(AlunosTurma, AlunosTurmaPath, AlunosPath)
    ;   write("\nAinda não há alunos nessa turma...\n\n")),
    print_purple_bold("\n=======================================\n").

print_alunos([], _, _).
print_alunos([H|T], AlunosTurmaPath, AlunosPath):-
    concat_atom([AlunosTurmaPath, "/", H], AlunoTurma),
    read_json(AlunoTurma, DadosTurma),
    Faltas = (DadosTurma.faltas),
    concat_atom([AlunosPath, "/", H], Aluno),
    read_json(Aluno, DadosAluno),
    Matricula = (DadosAluno.matricula),
    Nome = (DadosAluno.nome),
    print_white_bold(Matricula), print_white_bold(" - "), print_white_bold(Nome), print_white_bold(" ----- "), print_white_bold(Faltas), print_white_bold(" falta(s)\n"),
    print_alunos(T, AlunosTurmaPath, AlunosPath).

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
    print_purple_bold("===== ADICIONANDO NOTAS DO ALUNO ,"), print_purple_bold(Matricula), print_purple_bold(" ====="),
    print_purple_bold("\nDigite qual opção deseja: \n"),
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
    print_white_bold("\n==== SITUAÇÃO DO ALUNO "), print_white_bold(Matricula), print_white_bold(" ===\n\n"),
    print_white_bold("Nota 1: "), write(Nota1), nl,
    print_white_bold("Nota 2: "), write(Nota2), nl,
    print_white_bold("Nota 3: "), write(Nota2), nl,
    print_white_bold("Faltas: "), write(Faltas), nl,
    print_white_bold("Média: "), print_white_bold(Media), nl,
    situacao(Faltas, Media).

situacao(Faltas, _):- Faltas >= 8, print_red("\nREPROVADO POR FALTA :(\n"), !.
situacao(_, Media):- Media>=7.0, print_green("\nAPROVADO :)\n"), !.
situacao(_, Media):- Media>=4.0, print_yellow("\nFINAL :|\n").
situacao(_, Media):- print_red("\nREPROVADO :(\n").


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
    print_purple("\nDigite a matrícula do aluno que deseja alocar faltas ou "), print_white_bold('q'), print_purple(" para sair: \n"),
    read(Matricula),
    convert_to_string(Matricula, M),
    ((M == "q") -> nl ;
        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos/", Matricula, ".json"], Path),
        ((not_exists_file(Path))-> (print_red("\nAluno não está na turma.\n")) ;
            read_json(Path, Dados),
            Faltas is (Dados.faltas + 1),
            put_dict(faltas, Dados, Faltas, DadosGravados),
            write_json(Path, DadosGravados),
            print_green("\nFalta adicionada!\n")), nl,
            alocar_faltas(Disciplina, CodTurma)).

ver_relatorio(Disciplina, CodTurma):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos"], Path),
    directory_files(Path, Lista),
    remove_pontos(Lista, Alunos),
    medias_e_faltas(Alunos, Path, M, F),
    length(Alunos, Length),
    print_purple_bold("\nRELATÓRIO DA TURMA =======================================\n"),
    (Length > 0 ->
        Media is M/Length,
        Faltas is F/Length,
        print_white_bold("\nMédia de notas: "), write(Media), nl,
        print_white_bold("\nMédia de faltas: "), write(Faltas), nl
    ;   print_white_bold("\nNão há alunos para calcular a média de notas.\n"),
        print_white_bold("\nNão há alunos para calcular a média de faltas.\n")),
    print_purple_bold("\n==========================================================\n").

medias_e_faltas([], _, 0, 0).
medias_e_faltas([H|T], Path, M, F):-
    concat_atom([Path, "/", H], DadosPath),
    read_json(DadosPath, Dados),
    Media = (Dados.media),
    Falta = (Dados.faltas),
    medias_e_faltas(T, Path, Medias, Faltas),
    M is Medias + Media,
    F is Faltas + Falta.

ver_avaliacoes(Disciplina, CodTurma):-
    print_purple_bold("\nAVALIAÇÕES ====================================\n"),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/avaliacoes"], Path),
    directory_files(Path, Lista),
    remove_pontos(Lista, ListaDeAvaliacoes),
    length(ListaDeAvaliacoes, Length),
    (Length > 0 -> 
        media_avaliacoes(ListaDeAvaliacoes, Path, M),
        Media is M/Length,
        print_white_bold("\nNota média dada ao professor: "), write(Media), nl,
        print_avaliacoes(ListaDeAvaliacoes, Path)
    ;   print_red("\nAinda não há avaliações para o professor...\n")),
    print_purple_bold("\n===============================================\n").

print_avaliacoes([], _).
print_avaliacoes([H|T], Path):-
    concat_atom([Path, "/", H], AvaliacaoPath),
    read_json(AvaliacaoPath, Dados),
    Nota = (Dados.nota),
    Comentario = (Dados.comentario),
    formata_nota(Nota),
    print_white_bold("Comentário: "), write(Comentario), nl,
    print_avaliacoes(T, Path).

formata_nota(1):- print_yellow_bold("\n⭑☆☆☆☆\n").
formata_nota(2):- print_yellow_bold("\n⭑⭑☆☆☆\n").
formata_nota(3):- print_yellow_bold("\n⭑⭑⭑☆☆\n").
formata_nota(4):- print_yellow_bold("\n⭑⭑⭑⭑☆\n").
formata_nota(5):- print_yellow_bold("\n⭑⭑⭑⭑⭑\n").

media_avaliacoes([], _, 0).
media_avaliacoes([H|T], Path, M):-
    concat_atom([Path, "/", H], AvaliacaoPath),
    read_json(AvaliacaoPath, Dados),
    Nota = (Dados.nota),
    media_avaliacoes(T, Path, Media),
    M is Media + Nota.

materiais_didaticos_menu(Disciplina, CodTurma):-
    print_purple_bold("\nMATERIAIS DIDÁTICOS ============================\n"),
    print_purple("Escolha uma opção: \n"),
    write("[0] Voltar\n"),
    write("[1] Ver Materiais Didáticos\n"),
    write("[2] Adicionar novo Material Didático para turma\n"),
    print_purple_bold("===============================================\n"),
    read(Opcao),
    escolher_opcao_materiais_didaticos_menu(Opcao, Disciplina, CodTurma).

escolher_opcao_materiais_didaticos_menu(0, Disciplina, CodTurma):- turma_menu(Disciplina, CodTurma), !.
escolher_opcao_materiais_didaticos_menu(1, Disciplina, CodTurma):- ver_materiais_didaticos(Disciplina, CodTurma), materiais_didaticos_menu(Disciplina, CodTurma), !.
escolher_opcao_materiais_didaticos_menu(2, Disciplina, CodTurma):- adicionar_material_didatico(Disciplina, CodTurma), materiais_didaticos_menu(Disciplina, CodTurma), !.
escolher_opcao_materiais_didaticos_menu(_, Disciplina, CodTurma):- print_red("\nOpção inválida!\n").

ver_materiais_didaticos(Disciplina, CodTurma):- 
    print_white_bold("\n===== MATERIAIS DIDÁTICOS =====\n"),

    print_white_bold("\n================================\n").

adicionar_material_didatico(Disciplina, CodTurma):-
    print_purple("\nInsira o TÍTULO do Material Didático para toda turma ou "), print_white_bold("q"), print_purple(" para sair: \n"),
    read(Titulo),
    print_purple("\nInsira o CONTEÚDO do Material Didático para toda turma ou "), print_white_bold("q"), print_purple(" para sair: \n"),
    read(Conteudo).
