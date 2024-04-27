

:- initialization(main).
:- set_prolog_flag(encoding, utf8).

:- use_module("./Cadastro", [cadastroMenu/0]).
:- use_module("./Login", [loginMenu/0]).

main:-
    write("\n============== MENU INICIAL ===============\n"),
    write("[0] Sair \n"),
    write("[1] Cadastro \n"),
    write("[2] Login \n"),
    write("Marquin é calvo"),
    read(Opcao),
    escolherOpcao(Opcao),
    main.


escolherOpcao(0):- write("Saindo.. :)"), halt.
escolherOpcao(1):- cadastroMenu, !.
escolherOpcao(2):- loginMenu, !.
escolherOpcao(_):- write("\n Opcao invalida! \n").
