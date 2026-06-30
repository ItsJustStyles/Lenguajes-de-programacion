# Servicio de consulta de resultados finales del torneo.
#
# Encapsula la lógica de la Fase 9: identificar campeón, subcampeón y tercer
# lugar a partir de la final y del partido por el tercer puesto. Mantener esta
# lógica en un servicio evita repetir consultas en controladores y vistas.
#
# Uso:
#   FinalResultsService.new.call
#   # => { champion: Team, runner_up: Team, third_place: Team, finished: true }
class FinalResultsService
  def call
    {
      champion: champion,
      runner_up: runner_up,
      third_place: third_place,
      finished: finished?
    }
  end

  def finished?
    (final_match&.completed? && third_place_match&.completed?) || false
  end

  def champion
    final_match&.winner
  end

  def runner_up
    final_match&.loser
  end

  def third_place
    third_place_match&.winner
  end

  private

  def final_match
    @final_match ||= Match.final.where(status: :completed).first
  end

  def third_place_match
    @third_place_match ||= Match.third_place.where(status: :completed).first
  end
end
