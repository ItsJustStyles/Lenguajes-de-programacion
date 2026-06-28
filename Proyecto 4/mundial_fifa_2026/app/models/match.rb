# Representa un partido del torneo, tanto de fase de grupos como de
# eliminación directa.
#
# El mismo modelo cubre ambas fases para evitar duplicación: la fase se
# distingue con el enum `phase`. En eliminatoria los equipos pueden estar
# pendientes (TBD) hasta que se resuelva la ronda anterior, por eso las
# asociaciones de equipo son opcionales.
class Match < ApplicationRecord
  # Equipos participantes. Opcionales porque un cruce de eliminatoria puede
  # crearse antes de conocerse los clasificados.
  belongs_to :home_team, class_name: "Team", optional: true
  belongs_to :away_team, class_name: "Team", optional: true
  # Sólo los partidos de fase de grupos pertenecen a un grupo.
  belongs_to :group, optional: true

  # Fase del torneo. round_of_32 = dieciseisavos, round_of_16 = octavos.
  # Nota: se usa "group_stage" (no "group") porque "group" colisiona con el
  # método .group de ActiveRecord.
  enum phase: {
    group_stage: 0,
    round_of_32: 1,
    round_of_16: 2,
    quarter_final: 3,
    semi_final: 4,
    third_place: 5,
    final: 6
  }

  # Estado del partido: pendiente o finalizado (con resultado registrado).
  enum status: { pending: 0, completed: 1 }

  # Etiquetas legibles en español para mostrar la fase en la interfaz.
  PHASE_LABELS = {
    "group_stage" => "Fase de grupos",
    "round_of_32" => "Dieciseisavos de final",
    "round_of_16" => "Octavos de final",
    "quarter_final" => "Cuartos de final",
    "semi_final" => "Semifinales",
    "third_place" => "Partido por el tercer lugar",
    "final" => "Final"
  }.freeze

  # Validaciones de los goles: deben ser enteros no negativos cuando existen.
  validates :home_goals, :away_goals, :home_penalties, :away_penalties,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  # El enum ya provee el scope Match.group_stage. Aquí sólo añadimos el inverso
  # (todas las fases de eliminación directa) y un orden de cuadro.
  scope :knockout, -> { where.not(phase: :group_stage) }
  scope :ordered, -> { order(:phase, :match_number, :id) }

  # Nombre legible de la fase.
  def phase_label
    PHASE_LABELS[phase] || phase.humanize
  end

  # ¿Es un partido de eliminación directa?
  def knockout?
    !group_stage?
  end

  # ¿Terminó en empate en el tiempo reglamentario? (relevante para penales).
  def draw?
    completed? && home_goals == away_goals
  end

  # Devuelve la selección ganadora del partido o nil si no se puede determinar.
  # En eliminatoria, si hubo empate se decide por penales.
  def winner
    return nil unless completed? && home_team && away_team

    if home_goals > away_goals
      home_team
    elsif away_goals > home_goals
      away_team
    elsif knockout? # empate en reglamentario -> se define por penales
      decide_by_penalties
    end
  end

  # La selección perdedora (útil para el partido por el tercer lugar).
  def loser
    w = winner
    return nil unless w
    w == home_team ? away_team : home_team
  end

  # Marca el partido como finalizado tras registrar el resultado.
  def complete!
    update!(status: :completed)
  end

  def to_s
    home = home_team&.name || "Por definir"
    away = away_team&.name || "Por definir"
    "#{home} vs #{away}"
  end

  private

  # Resuelve el ganador por la tanda de penales. Devuelve nil si los penales
  # aún no se han cargado o están empatados (resultado inválido en eliminatoria).
  def decide_by_penalties
    return nil if home_penalties.nil? || away_penalties.nil?

    if home_penalties > away_penalties
      home_team
    elsif away_penalties > home_penalties
      away_team
    end
  end
end
