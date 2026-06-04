:- set_prolog_flag(encoding, utf8).
:- use_module(library(readutil)).
:- use_module(library(apply)).

:- consult('knowledge_base.pl').
:- consult('inference.pl').
:- consult('query_processor.pl').
:- consult('learning.pl').        
:- consult('conversation.pl').    

iniciar :-
    iniciar_conversacion,        
    bucle_conversacion.

bucle_conversacion :-
    write('Tu: '),
    leer_entrada(Entrada),
    ( es_comando_salida(Entrada)
    -> finalizar_conversacion      
    ;  manejar_turno(Entrada),    
       bucle_conversacion
    ).

leer_entrada(Palabras) :-
    read_line_to_string(user_input, Linea),
    normalizar_entrada(Linea, Palabras).

normalizar_entrada(Linea, Palabras) :-
    string_lower(Linea, LineaMin),
    split_string(LineaMin, " ", " ", Trozos),
    exclude(==(""), Trozos, TrozosLimpios),
    maplist(atom_string, Palabras, TrozosLimpios).

es_comando_salida(Palabras) :-
    member(Palabra, Palabras),
    palabra_salida(Palabra), !.

palabra_salida(salir).
palabra_salida(adios).
palabra_salida(chao).
palabra_salida(exit).
palabra_salida(quit).

responder(Palabras) :-
    obtener_respuesta(Palabras, Respuesta),
    format('Bot: ~w~n', [Respuesta]).

mostrar_bienvenida :-
    nl,
    write('==================================================='), nl,
    write('   Chatbot Inteligente - Paradigma Logico'), nl,
    write('==================================================='), nl,
    write('Hola! Puedo conversar y aprender contigo.'), nl,
    write('Escribe "salir" cuando quieras terminar.'), nl,
    nl.

mostrar_despedida :-
    nl,
    write('Bot: Hasta luego! Gracias por conversar.'), nl,
    nl.

:- initialization(iniciar, main).