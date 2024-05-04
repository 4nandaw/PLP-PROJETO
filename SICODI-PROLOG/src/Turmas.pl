

:- module(turma, [turma_menu/2, situacao_aluno/3, ver_mural/2, acessar_chat/3, print_aviso_chat/0, ver_materiais_didaticos/2]).
:- use_module(library(json)).
:- use_module("../utils/Utils").
:- use_module(library(filesex)).
:- use_module("./Disciplinas", [disciplina_menu/1]).

% :- use_module("../utils/Utils", [remove_pontos/2]).


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

escolher_opcao_turma_menu("7", Disciplina, CodTurma):- chat(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
escolher_opcao_turma_menu("6", Disciplina, CodTurma):- mural_menu(Disciplina, CodTurma), turma_menu(Disciplina, CodTurma), !.
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
    print_purple_bold("\n===== ADICIONANDO NOTAS DO ALUNO "), print_purple_bold(Matricula), print_purple_bold(" ====="),
    print_purple_bold("\nDigite uma opção: \n"),
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

chat(Disciplina, CodTurma):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/alunos"], Path),
    directory_files(Path, L),
    remove_pontos(L, ListaAlunos),
    ((lista_vazia(ListaAlunos)) -> 
            print_red("\nAinda não há alunos nessa turma para iniciar um chat!\n") ;
            (ver_alunos_turma(ListaAlunos),
            print_purple("\nDigite a matrícula do aluno ou "), print_white_bold("q"), print_purple(" para sair do chat: "),
            read(Matricula), 
            convert_to_string(Matricula, M)),
            ((M == "q") -> print_green("\nChat's encerrados\n") ;
                            concat_atom([Matricula, ".json"], MatriculaJ),
                            (member(MatriculaJ, ListaAlunos)) ->
                                    (print_purple_bold("\nMensagens anteriores: "),
                                    acessar_chat(Disciplina, CodTurma, Matricula),
                                    print_aviso_chat,
                                    enviar_mensagem_chat(Disciplina, CodTurma, Matricula), chat(Disciplina, CodTurma)) ;
                                    print_red("\nAluno não está na turma\n"), chat(Disciplina, CodTurma))).

print_aviso_chat:-
    print_red("\nAVISO:"), print_white_bold(" para parar de mandar mensagens aperte apenas ENTER").

ver_alunos_turma([]):- nl.
ver_alunos_turma([Matricula|T]):-
    concat_atom(["../db/alunos/", Matricula], Path),
    read_json(Path, Dados),
    nl, print_white_bold(Dados.matricula), print_white_bold("--"), print_white_bold(Dados.nome),
    ver_alunos_turma(T). 

acessar_chat(Disciplina, CodTurma, Matricula):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma,"/chats"], DirectoryPath),
    make_directory_path(DirectoryPath),
    concat_atom([DirectoryPath, "/", CodTurma, "-", Matricula, ".json"], Path),
    ((not_exists_file(Path)) -> 
        print_white_bold("Ainda não há nenhuma mensagem... inicie a conversa!") ;
        (read_json(Path, Dados),
        Chat = Dados.chat,
        ver_mensagens_anteriores(Chat)
        )
    ).


ver_mensagens_anteriores([]):- nl.
ver_mensagens_anteriores([[Remetente|Mensagem]|T2]):-
    nl, print_white_bold(Remetente), print_white_bold(": "), print_mensagem(Mensagem), ver_mensagens_anteriores(T2).

print_mensagem([Mensagem|T]):- print_white_bold(Mensagem).

enviar_mensagem_chat(Disciplina, CodTurma, Matricula):-
    write("\nMsg: "),
    read_line_to_string(user_input, Mensagem),
    ((Mensagem == "q") -> nl ;
        (salvar_mensagem(Disciplina, CodTurma, Matricula, Mensagem),
        enviar_mensagem_chat(Disciplina, CodTurma, Matricula))).

salvar_mensagem(Disciplina, CodTurma, Matricula, Mensagem):-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/chats/", CodTurma, "-", Matricula, ".json"], Path),
    concat_atom(["../db/disciplinas/", Disciplina, "/", Disciplina, ".json"], DisciplinePath),
    read_json(DisciplinePath, DadosDisciplina),
    NomeProf = DadosDisciplina.nome,
    (exists_file(Path)-> 
        (read_json(Path, Dados),
        Chat = Dados.chat,
        append(Chat, [[NomeProf, Mensagem]], ChatAtualizado),
        put_dict(chat, Dados, ChatAtualizado, DadosGravados),
        write_json(Path, DadosGravados)
        ) ;
        write_json(Path, _{chat : [[NomeProf, Mensagem]]})
    ).


mural_menu(Disciplina, CodTurma) :-
    print_purple_bold("\nMURAL DA TURMA ==============="),
    print_purple("\nEscolha uma opção: "),
    write("\n[0] Voltar\n"),
    write("[1] Ver Mural\n"),
    write("[2] Deixar aviso no Mural\n"),
    print_purple_bold("================================\n"),
    read(Opcao),
    convert_to_string(Opcao, Op),
    escolher_opcao_mural(Op, Disciplina, CodTurma).

escolher_opcao_mural("0", Disciplina, CodTurma) :- turma_menu(Disciplina, CodTurma), !.
escolher_opcao_mural("1", Disciplina, CodTurma) :- ver_mural(Disciplina, CodTurma), mural_menu(Disciplina, CodTurma), !.
escolher_opcao_mural("2", Disciplina, CodTurma) :- adicionar_aviso_mural(Disciplina, CodTurma), mural_menu(Disciplina, CodTurma), !.
escolher_opcao_mural(_, Disciplina, CodTurma) :- print_red("\nOpção inválida!\n"), mural_menu(Disciplina, CodTurma).

ver_mural(Disciplina, CodTurma) :-
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/mural/", CodTurma, ".json"], Path),
    (exists_file(Path) ->
        read_json(Path, Mural),
        (   get_dict(avisos, Mural, Avisos),
            Avisos \= []
        ->  print_white_bold("\nAvisos no Mural da Turma:\n\n"),
            reverse(Avisos, ReversedAvisos),
            print_avisos(ReversedAvisos, true)
        ;   print_red("\nAinda não há avisos no Mural da Turma.\n")
        )
    ; 
        print_red("\nAinda não há avisos no Mural da Turma.\n")
    ).

print_avisos([], _).
print_avisos([Aviso|Rest], IsFirst) :-
    (   IsFirst
    ->  print_blue_bold("+ "), write(Aviso), write("\n\n"),  % Se IsFirst for true, imprime com "+"
        print_avisos(Rest, false)
    ;   write("  "), write(Aviso), write("\n\n"),
        print_avisos(Rest, false)
    ).

adicionar_aviso_mural(Disciplina, CodTurma) :-
    print_purple("\nDigite o aviso para toda turma ou "), print_white_bold('q'), print_purple(" para sair: \n"),
    input(Aviso),

    (Aviso == "q" -> nl ;

        concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/mural/", CodTurma, ".json"], Path),
        (exists_file(Path) -> 
            read_json(Path, Mural),
            get_dict(avisos, Mural, Atuais),
            append(Atuais, [Aviso], NovosAvisos),
            MuralAtual = Mural.put(avisos, NovosAvisos)
        ;
            MuralAtual = _{avisos: [Aviso]}
        ),
        write_json(Path, MuralAtual),
        print_green("\nAviso adicionado ao Mural!\n")
    ).

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
    print_white_bold("\n=============== MATERIAIS DIDÁTICOS ===============\n"),
    concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/materiais/materiaisDidaticos.json"], Path),
    (exists_file(Path) ->
        read_json(Path, Materiais),
        (get_dict(materiaisDidaticos, Materiais, MateriaisDidaticos),
         MateriaisDidaticos \= [] ->
            reverse(MateriaisDidaticos, ReversedMateriaisDidaticos),
            print_materiais(ReversedMateriaisDidaticos, true)
        ;   print_red("\nAinda não há materiais didáticos disponíveis.\n")
        )
    ;   print_red("\nAinda não há materiais didáticos disponíveis.\n")
    ),
    print_white_bold("\n====================================================\n").

print_materiais([], _).
print_materiais([[Titulo,Conteudo]|T], IsFirst):-
    (IsFirst ->
        print_blue_bold("\n+ "), print_white_bold("Título do Material: "), write(Titulo),
        print_white_bold("\nConteúdo do Material: "), write(Conteudo), nl,
        print_materiais(T, false)
    ;   print_white_bold("\nTítulo do Material: "), write(Titulo),
        print_white_bold("\nConteúdo do Material: "), write(Conteudo), nl,
        print_materiais(T, false)
    ).

adicionar_material_didatico(Disciplina, CodTurma):-
    print_purple("\nInsira o TÍTULO do Material Didático para toda turma ou "), print_white_bold("q"), print_purple(" para sair: \n"),
    input(Titulo),
    print_purple("\nInsira o CONTEÚDO do Material Didático para toda turma ou "), print_white_bold("q"), print_purple(" para sair: \n"),
    read_line_to_string(user_input, Conteudo),
    (Titulo == "q"; Conteudo == "q" -> write("")
    ;   concat_atom(["../db/disciplinas/", Disciplina, "/turmas/", CodTurma, "/materiais/materiaisDidaticos.json"], Path),
        (exists_file(Path) ->
            read_json(Path, Materiais),
            get_dict(materiaisDidaticos, Materiais, Atuais),
            append(Atuais, [[Titulo, Conteudo]], NovosMateriais),
            MateriaisAtuais = Materiais.put(materiaisDidaticos, NovosMateriais)
        ;   MateriaisAtuais = _{materiaisDidaticos: [[Titulo, Conteudo]]}
        ),
        write_json(Path, MateriaisAtuais),
        print_green("\nMaterial didático registrado com sucesso!\n")
    ).
