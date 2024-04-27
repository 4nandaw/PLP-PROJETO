:- module(utils, [validando_dados/3,
escrever_json/2]).

:- use_module(library(http/json)).


validando_dados(Matricula, Nome, Senha):-
    dado_valido(Matricula), dado_valido(Nome), dado_valido(Senha).

dado_valido(Dado):- dif(Dado, ""), dif(Dado, " ").


ler_json(Caminho, D):-
    open(Caminho, read, Stream),
    json_read_dict(Stream, D),
    close(Stream).

escrever_json(Caminho, D):-
    open(Caminho, write, Stream),
    json_write_dict(Stream, D),
    close(Stream).