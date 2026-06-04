:- set_prolog_flag(encoding, utf8).

:- dynamic hecho_aprendido/3.

:- dynamic ruta_persistencia/1.

:- ( prolog_load_context(directory, Dir)
   -> atom_concat(Dir, '/learned_facts.pl', Ruta),
      assertz(ruta_persistencia(Ruta))
   ;  assertz(ruta_persistencia('learned_facts.pl'))
   ).

inicializar_aprendizaje :-
    ruta_persistencia(Ruta),
    ( exists_file(Ruta)
    -> catch(consult(Ruta),
             Error,
             format('Advertencia al cargar hechos previos (~w): ~w~n',
                    [Ruta, Error]))
    ;  true   
    ).

:- initialization(inicializar_aprendizaje, now).

tipo_valido(concepto).
tipo_valido(definicion).
tipo_valido(es_un).
tipo_valido(parte_de).
tipo_valido(propiedad).
tipo_valido(relacionado).
tipo_valido(sinonimo).

validar_nuevo_conocimiento(Tipo/Entidad/Valor) :-
    tipo_valido(Tipo),
    nonvar(Entidad), atom(Entidad),
    nonvar(Valor),   ( atom(Valor) ; string(Valor) ).

ensenar_hecho(Tipo, Entidad, Valor) :-
    validar_nuevo_conocimiento(Tipo/Entidad/Valor),
    Hecho =.. [Tipo, Entidad, Valor],
    \+ call(Hecho),                                
    assertz(Hecho),                                  
    assertz(hecho_aprendido(Tipo, Entidad, Valor)),
    guardar_hecho_en_archivo(Hecho).

olvidar_hecho(Tipo, Entidad, Valor) :-
    Hecho =.. [Tipo, Entidad, Valor],
    retract(Hecho),                                 
    ( retract(hecho_aprendido(Tipo, Entidad, Valor)) -> true ; true ),
    reescribir_archivo_persistencia.

corregir_hecho(Tipo, Entidad, ValorAntiguo, ValorNuevo) :-
    HechoViejo =.. [Tipo, Entidad, ValorAntiguo],
    ( retract(HechoViejo)                            
    -> ( retract(hecho_aprendido(Tipo, Entidad, ValorAntiguo)) -> true ; true )
    ;  true
    ),
    ensenar_hecho(Tipo, Entidad, ValorNuevo).        

guardar_hecho_en_archivo(Hecho) :-
    ruta_persistencia(Ruta),
    open(Ruta, append, Stream),
    format(Stream, ':- assertz(~q).~n', [Hecho]),
    close(Stream).

reescribir_archivo_persistencia :-
    ruta_persistencia(Ruta),
    findall(T/E/V, hecho_aprendido(T, E, V), Hechos),
    open(Ruta, write, Stream),
    format(Stream, '% Hechos aprendidos - generado automaticamente~n', []),
    maplist(escribir_en_stream(Stream), Hechos),
    close(Stream).

escribir_en_stream(Stream, Tipo/Entidad/Valor) :-
    Hecho =.. [Tipo, Entidad, Valor],
    format(Stream, ':- assertz(~q).~n', [Hecho]).

interpretar_ensenanza(Palabras, Respuesta) :-
    es_comando_aprendizaje(Palabras), !,
    ( procesar_ensenanza(Palabras, Tipo, Entidad, Valor)
    -> intentar_ensenar(Tipo, Entidad, Valor, Respuesta)
    ;  Respuesta = 'No entendi el formato. Prueba: "aprende que [termino] es [descripcion]".'
    ).

interpretar_ensenanza(Palabras, Respuesta) :-
    es_comando_olvido(Palabras), !,
    ( procesar_olvido(Palabras, Tipo, Entidad, Valor)
    -> intentar_olvidar(Tipo, Entidad, Valor, Respuesta)
    ;  Respuesta = 'No entendi que debo olvidar. Prueba: "olvida que [termino] es [descripcion]".'
    ).

es_comando_aprendizaje(Palabras) :-
    member(P, Palabras), palabra_aprendizaje(P), !.

es_comando_olvido(Palabras) :-
    member(P, Palabras), palabra_olvido(P), !.

palabra_aprendizaje(aprende).
palabra_aprendizaje(aprendeme).
palabra_aprendizaje(recuerda).
palabra_aprendizaje(sabias).
palabra_aprendizaje(sabe).
palabra_aprendizaje(ensenate).
palabra_aprendizaje(ensena).

% Vocabulario que activa el modo olvido / correccion
palabra_olvido(olvida).
palabra_olvido(olvidar).
palabra_olvido(corrige).
palabra_olvido(elimina).
palabra_olvido(borra).

procesar_ensenanza(Palabras, Tipo, Entidad, Valor) :-
    extraer_tras_que(Palabras, HechoPalabras),
    parsear_hecho(HechoPalabras, Tipo, Entidad, Valor).

% procesar_olvido(+Palabras, -Tipo, -Entidad, -Valor)
procesar_olvido(Palabras, Tipo, Entidad, Valor) :-
    extraer_tras_que(Palabras, HechoPalabras),
    parsear_hecho(HechoPalabras, Tipo, Entidad, Valor).

extraer_tras_que(Palabras, HechoPalabras) :-
    append(_, [que | HechoPalabras], Palabras),
    HechoPalabras \= [], !.

% "X es un tipo de Y" -> es_un(X, Y)
parsear_hecho(P, es_un, Entidad, Valor) :-
    append(XP, [es, un, tipo, de | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X es tipo de Y" -> es_un(X, Y)
parsear_hecho(P, es_un, Entidad, Valor) :-
    append(XP, [es, tipo, de | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X es parte de Y" -> parte_de(X, Y)
parsear_hecho(P, parte_de, Entidad, Valor) :-
    append(XP, [es, parte, de | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X es sinonimo de Y" -> sinonimo(X, Y)
parsear_hecho(P, sinonimo, Entidad, Valor) :-
    append(XP, [es, sinonimo, de | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X se relaciona con Y" -> relacionado(X, Y)
parsear_hecho(P, relacionado, Entidad, Valor) :-
    append(XP, [se, relaciona, con | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X es un Y" (sin "tipo de") -> es_un(X, Y)
parsear_hecho(P, es_un, Entidad, Valor) :-
    append(XP, [es, un | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, '_', Valor).

% "X es Y" -> concepto(X, descripcion) 
parsear_hecho(P, concepto, Entidad, Valor) :-
    append(XP, [es | YP], P),
    XP \= [], YP \= [], !,
    atomic_list_concat(XP, '_', Entidad),
    atomic_list_concat(YP, ' ', Valor).  

% Llama a ensenar_hecho/3 y construye la respuesta adecuada.
intentar_ensenar(Tipo, Entidad, Valor, Respuesta) :-
    ( ensenar_hecho(Tipo, Entidad, Valor)
    -> texto_termino(Entidad, Texto),
       format(atom(Respuesta),
              'Aprendido! Ahora se que ~w es ~w (registrado como ~w).',
              [Texto, Valor, Tipo])
    ;  texto_termino(Entidad, Texto),
       format(atom(Respuesta),
              'Ya tenia ese conocimiento sobre ~w registrado.',
              [Texto])
    ).

% intentar_olvidar(+Tipo, +Entidad, +Valor, -Respuesta)
% Llama a olvidar_hecho/3 y construye la respuesta adecuada.
intentar_olvidar(Tipo, Entidad, Valor, Respuesta) :-
    ( olvidar_hecho(Tipo, Entidad, Valor)
    -> texto_termino(Entidad, Texto),
       format(atom(Respuesta),
              'Entendido. He olvidado que ~w es ~w.',
              [Texto, Valor])
    ;  texto_termino(Entidad, Texto),
       format(atom(Respuesta),
              'No tenia ese hecho registrado sobre ~w.',
              [Texto])
    ).