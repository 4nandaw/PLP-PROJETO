

:- initialization(main).
:- set_prolog_flag(encoding, utf8).


:- use_module("./Cadastro", [cadastroMenu/0]).
:- use_module("./Login", [loginMenu/0]).


main:-
    write("\n============== MENU INICIAL ===============\n"),
    write("[0] Sair \n"),
    write("[1] Cadastro \n"),
    write("[2] Login \n"),
    read(Opcao),
    escolher_opcao(Opcao),
    main.



escolherOpcao(0):- write("Saindo.. :)"), halt.
escolherOpcao(1):- cadastro_menu, !.
escolherOpcao(2):- loginMenu, !.
escolherOpcao(_):- write("\n Opcao invalida! \n").

