# Servicio encargado de calcular la tabla de posiciones de un grupo.
#
# Responsabilidad única (SOLID/SRP): a partir de los partidos finalizados del
# grupo, recalcula desde cero las estadísticas de cada selección (puntos,
# goles, diferencia, victorias, etc.) y les asigna su posición (1 a 4).
#
# Criterios de ordenamiento, en orden de prioridad:
#   1. Puntos
#   2. Diferencia de goles
#   3. Goles a favor
#
# Uso:
#   StandingsCalculator.new(group).call
class StandingsCalculator
  # Puntos otorgados según el resultado de un partido.
  POINTS_FOR_WIN = 3
  POINTS_FOR_DRAW = 1
  POINTS_FOR_LOSS = 0

  def initialize(group)
    @group = group
  end

  # Recalcula y persiste la tabla del grupo. Devuelve las selecciones ordenadas.
  def call
    reset_all_stats
    accumulate_completed_matches
    assign_positions
  end

  private

  attr_reader :group

  # Deja todas las estadísticas en cero antes de recalcular, para que el método
  # sea siempre idempotente (puede llamarse tras editar cualquier resultado).
  def reset_all_stats
    group.teams.each(&:reset_stats!)
  end

  # Recorre los partidos finalizados del grupo y suma las estadísticas a cada
  # selección involucrada.
  def accumulate_completed_matches
    group.matches.where(status: :completed).each do |match|
      apply_result(match)
    end
  end

  # Aplica el resultado de un partido a las estadísticas de ambos equipos.
  def apply_result(match)
    home, away = match.home_team, match.away_team
    return unless home && away

    register_goals(home, match.home_goals, match.away_goals)
    register_goals(away, match.away_goals, match.home_goals)
    register_outcome(home, away, match.home_goals, match.away_goals)
  end

  # Acumula goles a favor/en contra, diferencia y partido jugado para un equipo.
  def register_goals(team, scored, conceded)
    team.goals_for += scored
    team.goals_against += conceded
    team.goal_difference += (scored - conceded)
    team.matches_played += 1
  end

  # Asigna puntos y registra victoria/empate/derrota a cada equipo.
  def register_outcome(home, away, home_goals, away_goals)
    if home_goals > away_goals
      win(home); loss(away)
    elsif away_goals > home_goals
      win(away); loss(home)
    else
      draw(home); draw(away)
    end
    home.save!
    away.save!
  end

  def win(team)
    team.wins += 1
    team.points += POINTS_FOR_WIN
  end

  def draw(team)
    team.draws += 1
    team.points += POINTS_FOR_DRAW
  end

  def loss(team)
    team.losses += 1
    team.points += POINTS_FOR_LOSS
  end

  # Ordena las selecciones por los criterios del torneo y guarda su posición.
  # Se recarga la asociación (reload) porque las estadísticas se actualizaron a
  # través de los objetos de los partidos, no de esta colección en caché.
  def assign_positions
    ordered = group.teams.reload.sort_by do |team|
      [-team.points, -team.goal_difference, -team.goals_for]
    end
    ordered.each_with_index do |team, index|
      team.update!(group_position: index + 1)
    end
    ordered
  end
end
