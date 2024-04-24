
- use_module(library(process)).




main:-
    shell(clear),
    write("\n============== MENU INICIAL ===============\n"),
    write("[0] Sair \n"),
    write("[1] Cadastro \n"),
    write("[2] Login \n"),
    read(Opcao),
    escolherOpcao(Opcao),
    main().

escolherOpcao(0):- write("Saindo.. :)"), halt.
escolherOpcao(1):- cadastro(), !.
escolherOpcao(2):- login(), !.
escolherOpcao(_):- write("\n Opcao invalida! \n").
