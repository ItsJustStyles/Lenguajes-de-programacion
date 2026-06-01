% ============================================================================
% main.pl - Punto de entrada del Chatbot Inteligente
% ----------------------------------------------------------------------------
% Proyecto 3: Chatbot Inteligente con Programacion Logica
% Paradigma Logico - I Semestre 2026
%
% Este modulo contiene el flujo conversacional principal:
%   - Lectura de la entrada del usuario por consola.
%   - Bucle de conversacion basado en recursividad (sin ciclos imperativos).
%   - Mecanismo de salida cuando el usuario lo indica.
%
% El procesamiento del lenguaje, las inferencias y el aprendizaje dinamico se
% delegan a modulos especificos que se integraran en fases posteriores.
% ============================================================================

:- set_prolog_flag(encoding, utf8).
:- use_module(library(readutil)).
:- use_module(library(apply)).

% --- Carga de modulos del proyecto -----------------------------------------
% Fase 2: base de conocimiento ya disponible. El resto se integra en sus
% fases. La carga es relativa al directorio de este archivo, por lo que
% funciona ejecutando "swipl src/main.pl" desde la raiz del proyecto.
:- consult('knowledge_base.pl').
:- consult('inference.pl').       % Fase 3
:- consult('query_processor.pl'). % Fase 4
% :- consult('learning.pl').        % Fase 5

% ============================================================================
% PUNTO DE ENTRADA
% ============================================================================

% iniciar/0
% Predicado principal. Muestra el saludo y arranca el bucle conversacional.
iniciar :-
    mostrar_bienvenida,
    bucle_conversacion.

% ============================================================================
% BUCLE CONVERSACIONAL
% ============================================================================

% bucle_conversacion/0
% Lee una linea del usuario y decide si continuar o terminar.
% La "iteracion" se logra mediante recursividad (paradigma logico),
% nunca con ciclos imperativos.
bucle_conversacion :-
    write('Tu: '),
    leer_entrada(Entrada),
    ( es_comando_salida(Entrada)
    -> mostrar_despedida
    ;  responder(Entrada),
       bucle_conversacion
    ).

% leer_entrada(-Entrada)
% Lee una linea completa de texto escrita por el usuario y la normaliza
% a una lista de atomos en minuscula (palabras), facilitando el procesamiento
% posterior por coincidencia de palabras clave.
leer_entrada(Palabras) :-
    read_line_to_string(user_input, Linea),
    normalizar_entrada(Linea, Palabras).

% normalizar_entrada(+Linea, -Palabras)
% Convierte la cadena leida en una lista de palabras en minuscula.
% Ej: "Que es Prolog?" -> [que, es, 'prolog?']
normalizar_entrada(Linea, Palabras) :-
    string_lower(Linea, LineaMin),
    split_string(LineaMin, " ", " ", Trozos),
    exclude(==(""), Trozos, TrozosLimpios),
    maplist(atom_string, Palabras, TrozosLimpios).

% ============================================================================
% CONTROL DE SALIDA
% ============================================================================

% es_comando_salida(+Palabras)
% Verdadero si la entrada del usuario corresponde a una orden de finalizar.
es_comando_salida(Palabras) :-
    member(Palabra, Palabras),
    palabra_salida(Palabra),
    !.

% palabra_salida/1 - Vocabulario que finaliza la conversacion.
palabra_salida(salir).
palabra_salida(adios).
palabra_salida(chao).
palabra_salida(exit).
palabra_salida(quit).

% ============================================================================
% SISTEMA DE RESPUESTAS
% ============================================================================

% responder(+Palabras)
% Delega la interpretacion de la pregunta y la construccion de la respuesta
% al sistema de inferencias. Ese sistema usa query_processor.pl para manejar
% variaciones como "Que es Prolog", "Explique Prolog" o "Defina Prolog".
responder(Palabras) :-
    obtener_respuesta(Palabras, Respuesta),
    format('Bot: ~w~n', [Respuesta]).

% ============================================================================
% MENSAJES DE INTERFAZ
% ============================================================================

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

% ============================================================================
% ARRANQUE AUTOMATICO
% ============================================================================
% Permite ejecutar:  swipl src/main.pl
% e iniciar el chatbot inmediatamente. El modo 'main' ejecuta iniciar/0 como
% objetivo principal y finaliza el proceso al terminar (sin caer en el
% interprete interactivo).
:- initialization(iniciar, main).
