# Representa una selección participante del Mundial.
#
# Guarda los datos del país y sus estadísticas acumuladas en la fase de grupos
# (puntos, goles a favor/en contra, diferencia de goles, etc.). El recálculo de
# estas estadísticas no se hace aquí, sino en los servicios de negocio, para
# mantener el modelo enfocado en los datos y sus relaciones (SOLID/SRP).
class Team < ApplicationRecord
  # Toda selección pertenece a un grupo.
  belongs_to :group

  # Una selección puede ser local o visitante en muchos partidos. Se definen
  # ambas asociaciones porque comparten la misma tabla "matches" pero con
  # claves foráneas distintas.
  has_many :home_matches, class_name: "Match", foreign_key: :home_team_id, dependent: :nullify
  has_many :away_matches, class_name: "Match", foreign_key: :away_team_id, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validate :group_has_capacity

  # Scopes útiles para consultar selecciones según su estado en el torneo.
  scope :qualified, -> { where(qualified: true) }
  scope :eliminated, -> { where(eliminated: true) }

  # Todos los partidos (de local y de visitante) en los que participó.
  def matches
    Match.where("home_team_id = :id OR away_team_id = :id", id: id)
  end

  # Reinicia las estadísticas de la fase de grupos a cero. Lo usa el servicio
  # StandingsCalculator antes de recalcular desde los resultados registrados.
  def reset_stats!
    update!(
      points: 0, goals_for: 0, goals_against: 0, goal_difference: 0,
      matches_played: 0, wins: 0, draws: 0, losses: 0, group_position: nil
    )
  end

  def to_s
    name
  end

  private

  # Evita que se registren más de 4 selecciones en un mismo grupo.
  def group_has_capacity
    return unless group

    current_count = group.teams.where.not(id: id).count
    if current_count >= Group::TEAMS_PER_GROUP
      errors.add(:group_id, "ya tiene #{Group::TEAMS_PER_GROUP} selecciones")
    end
  end
end
