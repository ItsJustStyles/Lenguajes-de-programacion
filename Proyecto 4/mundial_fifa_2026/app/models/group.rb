# Representa uno de los 12 grupos del Mundial (A a la L).
#
# Un grupo agrupa hasta 4 selecciones y los partidos de la fase de grupos que
# se disputan entre ellas. La lógica de cálculo de la tabla de posiciones vive
# en el servicio StandingsCalculator (principio de responsabilidad única).
class Group < ApplicationRecord
  # Cada grupo contiene varias selecciones y partidos de fase de grupos.
  has_many :teams, dependent: :destroy
  has_many :matches, dependent: :destroy

  # Cantidad de equipos que conforman un grupo según el formato del torneo.
  TEAMS_PER_GROUP = 4

  validates :name, presence: true, uniqueness: true

  # Orden natural por nombre (A, B, C, ...).
  default_scope { order(:name) }

  # Devuelve las selecciones del grupo ya ordenadas por posición en la tabla.
  # Si las posiciones aún no se han calculado, ordena por estadísticas.
  def standings
    teams.order(
      Arel.sql("group_position IS NULL, group_position ASC, points DESC, goal_difference DESC, goals_for DESC")
    )
  end

  # Indica si el grupo ya tiene el número completo de selecciones.
  def full?
    teams.count >= TEAMS_PER_GROUP
  end

  # Indica si todos los partidos de la fase de grupos de este grupo terminaron.
  def all_matches_completed?
    matches.any? && matches.all?(&:completed?)
  end

  def to_s
    "Grupo #{name}"
  end
end
