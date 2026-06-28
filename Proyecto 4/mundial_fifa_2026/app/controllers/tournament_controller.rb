# Controlador que orquesta el flujo general del torneo.
#
# Reúne las vistas y acciones que no pertenecen a un único recurso:
#   - standings:        panel principal con las tablas de los 12 grupos
#   - bracket:          cuadro de la fase de eliminación directa
#   - champion:         podio final (campeón, subcampeón y tercer lugar)
#   - generate_groups:  genera los 72 partidos de la fase de grupos
#   - generate_bracket: calcula clasificados y arma los dieciseisavos
#
# La lógica concreta vive en los servicios; aquí sólo se coordina (SOLID).
class TournamentController < ApplicationController
  before_action :load_status

  # GET / y /tournament/standings — tablas de posiciones de todos los grupos.
  def standings
    @groups = Group.includes(:teams).all
  end

  # GET /tournament/bracket — partidos de eliminación directa por fase.
  def bracket
    @matches_by_phase = Match.knockout
                             .includes(:home_team, :away_team)
                             .ordered
                             .group_by(&:phase)
  end

  # GET /tournament/champion — podio del torneo.
  def champion
    @podium = @status.podium
  end

  # POST /tournament/generate_groups — genera los partidos de la fase de grupos.
  def generate_groups
    if @status.group_stage_started?
      redirect_to tournament_standings_path, alert: "Los partidos de grupos ya fueron generados."
    else
      count = GroupFixtureGenerator.new.call
      redirect_to tournament_standings_path, notice: "Se generaron #{count} partidos de la fase de grupos."
    end
  end

  # POST /tournament/generate_bracket — clasifica y arma los dieciseisavos.
  def generate_bracket
    QualificationService.new.call
    BracketGenerator.new.call
    redirect_to tournament_bracket_path, notice: "Fase de eliminación directa generada."
  rescue QualificationService::GroupStageIncompleteError,
         BracketGenerator::NotEnoughQualifiedError => e
    redirect_to tournament_standings_path, alert: e.message
  end

  private

  # Estado global del torneo, disponible para todas las acciones y vistas.
  def load_status
    @status = TournamentStatusService.new
  end
end
