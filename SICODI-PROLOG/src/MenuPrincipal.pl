:- initialization(main).
:- set_prolog_flag(encoding, utf8).

:- use_module("./Cadastro", [cadastro_menu/0]).
:- use_module("./Login", [login_menu/0]).
:- use_module("../utils/Utils").

main:-
    write("\nMENU INICIAL ========\n"),
    write("[0] Sair\n"),
    write("[1] Cadastro\n"),
    write("[2] Login\n"),
    write("=====================\n"),
    read(Opcao),
    escolher_opcao(Opcao),
    main.

escolher_opcao(0):- write("\nSaindo... :)\n\n"), halt.
escolher_opcao(1):- cadastro_menu, !.
escolher_opcao(2):- login_menu, !.
escolher_opcao(_):- write("\nOPÇÃO INVÁLIDA!\n").