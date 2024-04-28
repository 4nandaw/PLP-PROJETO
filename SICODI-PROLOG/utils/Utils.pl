:- module(utils, [validando_dados/3,
write_json/2,
read_json/2, 
not_exists_file/1]).

:- use_module(library(http/json)).

validando_dados(Matricula, Nome, Senha):-
    dado_valido(Matricula), dado_valido(Nome), dado_valido(Senha).

dado_valido(Dado):- dif(Dado, ""), dif(Dado, " ").

not_exists_file(Path):-
    \+ exists_file(Path).

read_json(Path, D):-
    open(Path, read, Stream),
    json_read_dict(Stream, D),
    close(Stream).

write_json(Path, D):-
    open(Path, write, Stream),
    json_write_dict(Stream, D),
    close(Stream).