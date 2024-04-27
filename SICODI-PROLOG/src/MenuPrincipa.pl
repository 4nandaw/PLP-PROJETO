

:- initialization(main).

:- use_module("./Cadastro", [cadastro_menu/0]).

main:-
    write("\n============== MENU INICIAL ===============\n"),
    write("[0] Sair \n"),
    write("[1] Cadastro \n"),
    write("[2] Login \n"),
    read(Opcao),
    escolher_opcao(Opcao),
    main.




escolher_opcao(0):- cls, write("Saindo.. :)"), halt.
escolher_opcao(1):- cadastro_menu, !.
/*escolherOpcao(2):- loginMenu, !.*/
escolher_opcao(_):- write("\n Opcao invalida! \n").
