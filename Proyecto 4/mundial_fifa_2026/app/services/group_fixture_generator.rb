# Servicio que genera los partidos de la fase de grupos.
#
# En cada grupo de 4 equipos se juegan todos contra todos una sola vez, lo que
# produce C(4,2) = 6 partidos por grupo (72 en total para los 12 grupos).
#
# Es idempotente: si un grupo ya tiene partidos generados, no los duplica.
#
# Uso:
#   GroupFixtureGenerator.new.call            # genera para todos los grupos
#   GroupFixtureGenerator.new(group).call     # genera sólo para un grupo
class GroupFixtureGenerator
  def initialize(group = nil)
    @groups = group ? [group] : Group.all.to_a
  end

  # Genera los enfrentamientos faltantes y devuelve la cantidad creada.
  def call
    created = 0
    @groups.each do |group|
      created += generate_for(group)
    end
    created
  end

  private

  # Crea los partidos round-robin de un grupo si todavía no existen.
  def generate_for(group)
    return 0 if group.matches.exists? # ya generados: se respeta la idempotencia

    teams = group.teams.to_a
    number = 0
    # combination(2) produce cada par de equipos una única vez.
    teams.combination(2).map do |home, away|
      number += 1
      Match.create!(
        group: group,
        home_team: home,
        away_team: away,
        phase: :group_stage,
        status: :pending,
        match_number: number
      )
    end.size
  end
end
