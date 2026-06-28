# Servicio que genera el cuadro de dieciseisavos de final (round_of_32) a
# partir de las 32 selecciones clasificadas.
#
# Siembra (seeding):
#   Las 32 clasificadas se ordenan en una lista de "cabezas de serie":
#     1) los 12 primeros lugares de grupo (mejor a peor)
#     2) los 12 segundos lugares de grupo
#     3) los 8 mejores terceros
#   El equipo mejor ubicado es la siembra #1 y el peor la #32.
#
# Con esa lista se construye un cuadro de eliminación equilibrado usando la
# siembra clásica (1 vs 32, 16 vs 17, ...), de modo que las dos mejores
# selecciones sólo podrían enfrentarse en la final. Los partidos se numeran en
# orden de cuadro para que el avance entre rondas sea directo.
#
# Es idempotente: si ya existen los dieciseisavos, no los vuelve a crear.
#
# Uso:
#   BracketGenerator.new.call
class BracketGenerator
  # Error si se intenta armar el cuadro sin los 32 clasificados.
  class NotEnoughQualifiedError < StandardError; end

  QUALIFIED_COUNT = 32

  def call
    return Match.round_of_32.ordered.to_a if Match.round_of_32.exists?

    seeds = seeded_qualified_teams
    if seeds.size != QUALIFIED_COUNT
      raise NotEnoughQualifiedError,
            "Se requieren #{QUALIFIED_COUNT} clasificados y hay #{seeds.size}."
    end

    create_round_of_32(seeds)
  end

  private

  # Lista de clasificados ordenada por siembra (índice 0 = siembra #1).
  def seeded_qualified_teams
    firsts  = ranked(Team.qualified.where(group_position: 1))
    seconds = ranked(Team.qualified.where(group_position: 2))
    thirds  = ranked(Team.qualified.where(group_position: 3))
    firsts + seconds + thirds
  end

  # Ordena un conjunto de equipos por los criterios del torneo.
  def ranked(relation)
    relation.to_a.sort_by { |t| [-t.points, -t.goal_difference, -t.goals_for] }
  end

  # Crea los 16 partidos de dieciseisavos emparejando según el orden de cuadro.
  def create_round_of_32(seeds)
    order = bracket_seed_order(QUALIFIED_COUNT) # ej. [1,32,16,17,8,25,...]
    number = 0
    order.each_slice(2).map do |seed_a, seed_b|
      number += 1
      Match.create!(
        phase: :round_of_32,
        status: :pending,
        match_number: number,
        home_team: seeds[seed_a - 1],
        away_team: seeds[seed_b - 1]
      )
    end
  end

  # Genera el orden de siembra clásico para un cuadro de n participantes.
  # Para n = 4 devuelve [1, 4, 2, 3]; para n = 8 [1,8,4,5,2,7,3,6]; etc.
  def bracket_seed_order(n)
    order = [1]
    while order.size < n
      size = order.size * 2
      order = order.flat_map { |seed| [seed, size + 1 - seed] }
    end
    order
  end
end
