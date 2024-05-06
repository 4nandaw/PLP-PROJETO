:- module(utils, [validando_dados/3,
write_json/2,
read_json/2, 
not_exists_file/1,
convert_to_string/2,
limparTela/0,
remove_pontos/2,
print_yellow/1,
print_yellow_bold/1,
print_blue/1,
print_blue_bold/1,
print_purple/1,
print_purple_bold/1,
print_red/1,
print_green/1,
print_white_bold/1,
trim_whitespace/2,
lista_vazia/1]).

:- use_module(library(http/json)).
:- use_module(library(ansi_term)).

limparTela:-
    (   current_prolog_flag(unix, true) % Verifica se é linux e limpa, se não limpa para outros OS.
    ->  shell(clear)                    
    ;   process_create(path(cmd), ['/C', 'cls'], [process(PID)]),
        process_wait(PID, _Status)      
    ).

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

convert_to_string(Data, String):-
    (
        atom(Data) ->
        atom_string(Data, String)
    ;
        number(Data) ->
        atom_string(Data, String)
    ;
        string(Data) ->
        String = Data
    ;
        term_string(Data, String)
    ).
    
remove_pontos(List, CleanList) :-
    exclude(is_dot_or_dotdot, List, CleanList).

is_dot_or_dotdot('.').
is_dot_or_dotdot('..').

print_yellow(Texto):-
    ansi_format([fg(yellow)], '~w', [Texto]).

print_yellow_bold(Texto):-
    ansi_format([bold, fg(yellow)], '~w', [Texto]).

print_blue(Texto):-
    ansi_format([fg(blue)], '~w', [Texto]).

print_blue_bold(Texto):-
    ansi_format([bold, fg(blue)], '~w', [Texto]).

print_purple(Texto):-
    ansi_format([fg(magenta)], '~w', [Texto]).

print_purple_bold(Texto):-
    ansi_format([bold, fg(magenta)], '~w', [Texto]).

print_red(Texto):-
    ansi_format([fg(red)], '~w', [Texto]).

print_green(Texto):-
    ansi_format([fg(green)], '~w', [Texto]).

print_white_bold(Texto):-
    ansi_format([bold, fg(white)], '~w', [Texto]).

trim_whitespace(String, Trimmed) :-
    atom_string(Atom, String),
    atom_string(TrimmedAtom, Atom),
    atom_string(TrimmedAtom, Trimmed).

lista_vazia([]).