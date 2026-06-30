# Servicio que registra el resultado de un partido y dispara los efectos
# correspondientes según la fase.
#
# Orquesta a otros servicios (principio de responsabilidad única: aquí sólo se
# coordina, el cálculo concreto vive en cada servicio):
#   - Fase de grupos: recalcula la tabla del grupo (StandingsCalculator).
#   - Eliminatoria:   intenta avanzar a la siguiente ronda (KnockoutAdvancer).
#
# Uso:
#   MatchResultProcessor.new(match).call(home_goals: 2, away_goals: 1)
#   MatchResultProcessor.new(match).call(
#     home_goals: 1, away_goals: 1, home_penalties: 4, away_penalties: 3
#   )
class MatchResultProcessor
  # Error de validación de un resultado de eliminatoria (debe haber ganador).
  class InvalidResultError < StandardError; end

  def initialize(match)
    @match = match
  end

  # Registra el resultado y ejecuta los efectos secundarios. Devuelve el match.
  def call(home_goals:, away_goals:, home_penalties: nil, away_penalties: nil)
    assign_result(home_goals, away_goals, home_penalties, away_penalties)
    validate_knockout_has_winner!
    @match.save!
    @match.complete!
    propagate_effects
    @match
  end

  private

  attr_reader :match

  # Asigna los goles (y penales si aplican) al partido.
  def assign_result(home_goals, away_goals, home_penalties, away_penalties)
    match.home_goals = home_goals
    match.away_goals = away_goals
    # Los penales sólo tienen sentido en eliminatoria y con empate.
    if match.knockout? && home_goals == away_goals
      match.home_penalties = home_penalties
      match.away_penalties = away_penalties
    else
      match.home_penalties = nil
      match.away_penalties = nil
    end
  end

  # En eliminatoria no puede haber empate final: si hay empate en goles, los
  # penales deben definir un ganador.
  def validate_knockout_has_winner!
    return unless match.knockout?
    return unless match.home_goals == match.away_goals

    pen_home = match.home_penalties
    pen_away = match.away_penalties
    if pen_home.nil? || pen_away.nil? || pen_home == pen_away
      raise InvalidResultError,
            "En eliminación directa un empate debe definirse por penales con un ganador."
    end
  end

  # Dispara el recálculo o el avance según la fase del partido.
  def propagate_effects
    if match.group_stage?
      StandingsCalculator.new(match.group).call
      # Si este resultado completó la fase de grupos, se calculan los 32
      # clasificados y se genera automáticamente el cuadro de dieciseisavos.
      AutoBracketService.new.call
    else
      # En eliminatoria, cuando una ronda queda completa, se crean los cruces
      # de la siguiente ronda y, desde semifinales, también el partido por el
      # tercer lugar y la final.
      KnockoutAdvancer.new.call
    end
  end
end
