:- initialization(main).
:- set_prolog_flag(encoding, utf8).

:- use_module("./Cadastro", [cadastro_menu/0]).
:- use_module("./Login", [login_menu/0]).
:- use_module("../utils/Utils").

main:-
    print_yellow_bold("\nMENU INICIAL ========\n"),
    print_yellow("[0] Sair\n"),
    print_yellow("[1] Cadastro\n"),
    print_yellow("[2] Login\n"),
    print_yellow_bold("=====================\n"),
    read(Opcao),
    escolher_opcao(Opcao),
    main.

escolher_opcao(0):- print_green("\nSaindo... :)\n\n"), halt.
escolher_opcao(1):- cadastro_menu, !.
escolher_opcao(2):- login_menu, !.
escolher_opcao(_):- print_red("\nOpção inválida.\n").