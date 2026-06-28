# Servicio que hace avanzar la fase de eliminación directa.
#
# Cuando TODOS los partidos de una ronda están finalizados, genera los partidos
# de la siguiente ronda emparejando a los ganadores de partidos consecutivos
# (ganador del partido 1 vs ganador del partido 2, etc.). Esto funciona porque
# el BracketGenerator numeró los dieciseisavos en orden de cuadro.
#
# Caso especial de las semifinales:
#   - los GANADORES juegan la final
#   - los PERDEDORES juegan el partido por el tercer lugar
#
# Es idempotente: si la siguiente ronda ya existe, no hace nada.
#
# Uso:
#   KnockoutAdvancer.new.call   # intenta avanzar todas las rondas posibles
class KnockoutAdvancer
  # Secuencia de rondas y la fase que generan al completarse.
  NEXT_PHASE = {
    "round_of_32" => "round_of_16",
    "round_of_16" => "quarter_final",
    "quarter_final" => "semi_final",
    "semi_final" => "final" # también dispara el partido por el tercer lugar
  }.freeze

  # Intenta avanzar todas las rondas que ya estén completas. Devuelve la lista
  # de fases que se generaron en esta llamada.
  def call
    generated = []
    NEXT_PHASE.each_key do |phase|
      next unless round_complete?(phase)

      created = advance_from(phase)
      generated.concat(created) if created.any?
    end
    generated
  end

  private

  # ¿Existen partidos de esa fase y están todos finalizados?
  def round_complete?(phase)
    matches = Match.where(phase: phase)
    matches.any? && matches.all?(&:completed?)
  end

  # Genera la(s) fase(s) siguiente(s) a partir de una ronda completa.
  def advance_from(phase)
    if phase == "semi_final"
      advance_semifinals
    else
      advance_regular(phase)
    end
  end

  # Avance estándar: empareja ganadores de partidos consecutivos.
  def advance_regular(phase)
    next_phase = NEXT_PHASE[phase]
    return [] if Match.where(phase: next_phase).exists?

    winners = Match.where(phase: phase).ordered.map(&:winner)
    return [] if winners.any?(&:nil?) # algún ganador no determinado (faltan penales)

    create_pairings(winners, next_phase)
  end

  # Caso especial: de semifinales salen la final y el partido por el 3.er lugar.
  def advance_semifinals
    return [] if Match.final.exists? || Match.third_place.exists?

    semis = Match.semi_final.ordered.to_a
    winners = semis.map(&:winner)
    losers  = semis.map(&:loser)
    return [] if winners.any?(&:nil?) || losers.any?(&:nil?)

    created = []
    created << Match.create!(
      phase: :third_place, status: :pending, match_number: 1,
      round: "Partido por el tercer lugar",
      home_team: losers[0], away_team: losers[1]
    )
    created << Match.create!(
      phase: :final, status: :pending, match_number: 1, round: "Final",
      home_team: winners[0], away_team: winners[1]
    )
    created
  end

  # Crea los partidos de la siguiente ronda emparejando la lista de ganadores
  # de dos en dos.
  def create_pairings(winners, next_phase)
    number = 0
    winners.each_slice(2).map do |home, away|
      number += 1
      Match.create!(
        phase: next_phase,
        status: :pending,
        match_number: number,
        home_team: home,
        away_team: away
      )
    end
  end
end
