

:- initialization(main).

:- use_module("./Cadastro", [cadastroMenu/0]).

main:-
    write("\n============== MENU INICIAL ===============\n"),
    write("[0] Sair \n"),
    write("[1] Cadastro \n"),
    write("[2] Login \n"),
    limparTela,
    write("Marquin é calvo"),
    read(Opcao),
    escolherOpcao(Opcao),
    main.


escolherOpcao(0):- write("Saindo.. :)"), halt.
escolherOpcao(1):- cadastroMenu, !.
/*escolherOpcao(2):- login(), !.*/
escolherOpcao(_):- write("\n Opcao invalida! \n").
