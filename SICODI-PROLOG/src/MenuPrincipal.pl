:- initialization(main).
:- set_prolog_flag(encoding, utf8).
:- use_module(library(readutil)).
:- use_module("./Cadastro", [cadastro_menu/0]).
:- use_module("./Login", [login_menu/0]).
:- use_module("../utils/Utils").
:- set_prolog_flag(encoding, utf8).


main:-
    print_yellow_bold("\nMENU INICIAL ========\n"),
    print_yellow_bold("Digite uma opção: \n"),
    write("[0] Sair\n"),
    write("[1] Cadastro\n"),
    write("[2] Login\n"),
    print_yellow_bold("=====================\n"),
    read_line_to_string(user_input, Opcao),
    escolher_opcao(Opcao),
    main.

escolher_opcao("0"):- print_green("\nPrograma finalizado! :)\n\n"), halt.
escolher_opcao("1"):- cadastro_menu, !.
escolher_opcao("2"):- login_menu, !.
escolher_opcao(_):- print_red("\nOpção inválida.\n").