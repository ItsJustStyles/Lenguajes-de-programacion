# Fases 8 y 9 - Implementación técnica

Proyecto 4 - Sistema de Gestión de la Copa Mundial FIFA 2026

## Fase 8: Fase eliminatoria

La fase eliminatoria queda implementada con cruces desde dieciseisavos de final hasta la final. El flujo completo es:

1. Al completarse la fase de grupos, `AutoBracketService` calcula los 32 clasificados y genera automáticamente los 16 partidos de dieciseisavos.
2. `BracketGenerator` ordena a los clasificados por siembra y arma el cuadro inicial.
3. Cada resultado se registra mediante `MatchResultProcessor`.
4. Si un partido eliminatorio empata en goles, el sistema exige penales con ganador.
5. Cuando todos los partidos de una ronda están finalizados, `KnockoutAdvancer` genera la siguiente ronda automáticamente.
6. Al completarse semifinales, se crean tanto la final como el partido por el tercer lugar.

Archivos principales:

| Archivo | Responsabilidad |
|---|---|
| `app/services/auto_bracket_service.rb` | Genera automáticamente dieciseisavos cuando termina la fase de grupos. |
| `app/services/bracket_generator.rb` | Arma el cuadro inicial de 32 clasificados. |
| `app/services/knockout_advancer.rb` | Avanza de ronda en ronda hasta final y tercer lugar. |
| `app/services/match_result_processor.rb` | Guarda resultados, valida penales y dispara recálculos/avances. |
| `app/views/tournament/bracket.html.erb` | Muestra el cuadro eliminatorio por ronda. |
| `app/views/matches/edit.html.erb` | Permite registrar goles y penales. |

## Fase 9: Resultados finales

La fase de resultados finales queda centralizada en `FinalResultsService` y se muestra en la vista de campeón.

El sistema determina:

- Campeón: ganador de la final.
- Subcampeón: perdedor de la final.
- Tercer lugar: ganador del partido por el tercer lugar.

Archivos principales:

| Archivo | Responsabilidad |
|---|---|
| `app/services/final_results_service.rb` | Consulta campeón, subcampeón, tercer lugar y estado final. |
| `app/services/tournament_status_service.rb` | Expone el estado global del torneo para la interfaz. |
| `app/controllers/tournament_controller.rb` | Carga el podio para la vista final. |
| `app/views/tournament/champion.html.erb` | Muestra el podio final. |

## Pruebas agregadas

Se agregó el archivo:

```bash
test/services/phase_8_9_flow_test.rb
```

Escenarios cubiertos:

1. Al completar el último partido de grupos se generan automáticamente los dieciseisavos.
2. Un empate de eliminatoria exige penales con ganador.
3. La eliminatoria avanza automáticamente por dieciseisavos, octavos, cuartos, semifinales, tercer lugar y final.
4. Al finalizar el torneo existe campeón, subcampeón y tercer lugar.

Para ejecutar las pruebas:

```bash
cd "Proyecto 4/mundial_fifa_2026"
bin/rails test test/services/phase_8_9_flow_test.rb
```
