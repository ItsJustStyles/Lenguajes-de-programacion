# Servicio de consulta del estado global del torneo.
#
# Centraliza las preguntas que la interfaz necesita responder: ¿en qué fase
# vamos?, ¿se puede ya calcular la clasificación?, ¿quién es el campeón? Así los
# controladores y vistas no repiten esa lógica (SOLID/DRY).
#
# Uso:
#   status = TournamentStatusService.new
#   status.current_phase   # => :group_stage, :knockout, :finished, :not_started
#   status.champion        # => Team o nil
class TournamentStatusService
  # ¿Ya se generaron los partidos de fase de grupos?
  def group_stage_started?
    Match.group_stage.exists?
  end

  # ¿Terminaron todos los partidos de la fase de grupos?
  def group_stage_complete?
    matches = Match.group_stage
    matches.any? && matches.where.not(status: Match.statuses[:completed]).none?
  end

  # ¿Ya se generó el cuadro de eliminación directa?
  def knockout_started?
    Match.knockout.exists?
  end

  # ¿Se puede calcular la clasificación y generar el cuadro?
  # (grupos completos pero cuadro aún no generado)
  def ready_for_knockout?
    group_stage_complete? && !knockout_started?
  end

  # ¿El torneo terminó? (final finalizada)
  def finished?
    Match.final.where(status: :completed).exists?
  end

  # Fase actual del torneo como símbolo, útil para el panel principal.
  def current_phase
    return :finished if finished?
    return :knockout if knockout_started?
    return :group_stage if group_stage_started?

    :not_started
  end

  # Campeón del Mundial (ganador de la final) o nil.
  def champion
    final = Match.final.where(status: :completed).first
    final&.winner
  end

  # Subcampeón (perdedor de la final) o nil.
  def runner_up
    final = Match.final.where(status: :completed).first
    final&.loser
  end

  # Tercer lugar (ganador del partido por el tercer lugar) o nil.
  def third_place
    match = Match.third_place.where(status: :completed).first
    match&.winner
  end

  # Devuelve el podio como hash, para mostrarlo cómodamente en la vista.
  def podium
    { champion: champion, runner_up: runner_up, third_place: third_place }
  end
end
