# Servicio que determina las 32 selecciones clasificadas a la fase de
# eliminación directa, según el formato del Mundial 2026:
#
#   - 1.º y 2.º lugar de cada uno de los 12 grupos  -> 24 equipos
#   - los 8 mejores terceros lugares                 ->  8 equipos
#                                                       --------------
#                                                        32 equipos
#
# Los terceros se comparan ENTRE SÍ (no contra su propio grupo) por:
# puntos, diferencia de goles y goles a favor.
#
# Marca cada selección como `qualified` o `eliminated` y devuelve la lista de
# clasificados. Requiere que la fase de grupos esté completa.
#
# Uso:
#   QualificationService.new.call
class QualificationService
  # Cuántos terceros lugares clasifican.
  BEST_THIRDS_COUNT = 8

  # Error que se lanza si se intenta calcular antes de terminar los grupos.
  class GroupStageIncompleteError < StandardError; end

  # Calcula los clasificados. Devuelve un arreglo con las 32 selecciones.
  # Si raise_on_incomplete es false, devuelve [] cuando aún no se puede.
  def call(raise_on_incomplete: true)
    unless group_stage_complete?
      raise GroupStageIncompleteError, "La fase de grupos aún no ha finalizado." if raise_on_incomplete
      return []
    end

    reset_flags
    qualified = direct_qualifiers + best_third_place_qualifiers
    mark_qualified(qualified)
    mark_eliminated(qualified)
    qualified
  end

  private

  # ¿Terminaron todos los partidos de todos los grupos?
  def group_stage_complete?
    matches = Match.group_stage
    matches.any? && matches.where.not(status: Match.statuses[:completed]).none?
  end

  # Limpia las banderas antes de recalcular, para mantener idempotencia.
  def reset_flags
    Team.update_all(qualified: false, eliminated: false)
  end

  # Primeros y segundos lugares de cada grupo (24 equipos).
  def direct_qualifiers
    Group.all.flat_map do |group|
      group.teams.where(group_position: [1, 2]).to_a
    end
  end

  # Los 8 mejores terceros, ordenados entre sí por los criterios del torneo.
  def best_third_place_qualifiers
    thirds = Team.where(group_position: 3).to_a
    thirds.sort_by { |t| [-t.points, -t.goal_difference, -t.goals_for] }
          .first(BEST_THIRDS_COUNT)
  end

  def mark_qualified(teams)
    Team.where(id: teams.map(&:id)).update_all(qualified: true)
  end

  # Toda selección que no clasificó queda eliminada.
  def mark_eliminated(qualified)
    Team.where.not(id: qualified.map(&:id)).update_all(eliminated: true)
  end
end
