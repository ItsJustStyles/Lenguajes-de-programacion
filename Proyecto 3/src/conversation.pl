:- set_prolog_flag(encoding, utf8).

:- dynamic conversacion_activa/0.
:- dynamic mensajes_bienvenida/1.
:- dynamic mensajes_despedida/1.
:- dynamic mensajes_sin_conocimiento/1.
:- dynamic turno_numero/1.

turno_numero(0).

mensajes_bienvenida('Hola! Soy un asistente logico. Puedo responder preguntas y aprender de ti.').
mensajes_bienvenida('Bienvenido! Preguntame sobre conceptos, relaciones o ensename algo nuevo.').
mensajes_bienvenida('Hola! Combino inferencia logica con aprendizaje dinamico. En que te ayudo?').

mensajes_despedida('Hasta luego! Gracias por conversar y ensenyarme.').
mensajes_despedida('Adios! El conocimiento que compartiste queda guardado para la proxima sesion.').
mensajes_despedida('Chao! Fue un placer razonar contigo hoy.').

mensajes_sin_conocimiento('No tengo informacion sobre eso. Puedes ensenyarme con: "aprende que [termino] es [descripcion]".').
mensajes_sin_conocimiento('Ese tema no esta en mi base de conocimiento. Usa "aprende que X es Y" para ensenyarme.').
mensajes_sin_conocimiento('No encontre datos sobre eso. Escribe "aprende que [concepto] es [explicacion]" si quieres que lo recuerde.').


iniciar_conversacion :-
    assertz(conversacion_activa),    
    actualizar_turno(0),
    mensaje_aleatorio(mensajes_bienvenida, Msg),
    nl,
    write('==================================================='), nl,
    write('   Chatbot Inteligente - Paradigma Logico'), nl,
    write('==================================================='), nl,
    format('Bot: ~w~n', [Msg]),
    nl,
    write('  Comandos disponibles:'), nl,
    write('  - "aprende que [X] es [Y]"           -> enseñar un concepto'), nl,
    write('  - "aprende que [X] es un tipo de [Y]" -> enseñar una jerarquia'), nl,
    write('  - "aprende que [X] es parte de [Y]"   -> enseñar composicion'), nl,
    write('  - "olvida que [X] es [Y]"             -> olvidar un hecho'), nl,
    write('  - "salir" / "adios" / "chao"          -> finalizar'), nl,
    nl.

finalizar_conversacion :-
    retractall(conversacion_activa),     
    mensaje_aleatorio(mensajes_despedida, Msg),
    nl,
    format('Bot: ~w~n', [Msg]),
    nl.

manejar_turno(Palabras) :-
    incrementar_turno,
    manejar_segun_intencion(Palabras).

manejar_segun_intencion(Palabras) :-
    (   ( current_predicate(es_comando_aprendizaje/1),
          es_comando_aprendizaje(Palabras) )
    ;   ( current_predicate(es_comando_olvido/1),
          es_comando_olvido(Palabras) )
    ), !,
    ( current_predicate(interpretar_ensenanza/2)
    -> interpretar_ensenanza(Palabras, Respuesta)
    ;  Respuesta = 'El modulo de aprendizaje no esta disponible.'
    ),
    format('Bot: ~w~n', [Respuesta]).

manejar_segun_intencion(Palabras) :-
    obtener_respuesta(Palabras, RespuestaRaw),
    ( respuesta_sin_conocimiento(RespuestaRaw)
    -> mensaje_aleatorio(mensajes_sin_conocimiento, Respuesta)
    ;  Respuesta = RespuestaRaw
    ),
    format('Bot: ~w~n', [Respuesta]).

incrementar_turno :-
    turno_numero(N),
    N1 is N + 1,
    actualizar_turno(N1).

actualizar_turno(N) :-
    retractall(turno_numero(_)),
    assertz(turno_numero(N)).

mensaje_aleatorio(Predicado, Mensaje) :-
    findall(M, call(Predicado, M), Lista),
    Lista \= [],
    length(Lista, N),
    random_between(1, N, Idx),
    nth1(Idx, Lista, Mensaje), !.
mensaje_aleatorio(_, '...').

respuesta_sin_conocimiento(R) :-
    atom(R),
    (   sub_atom(R, _, _, _, 'No tengo informacion')
    ;   sub_atom(R, _, _, _, 'No encontre una palabra clave')
    ).