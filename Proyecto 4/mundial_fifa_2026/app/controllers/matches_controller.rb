# Controlador de partidos.
#
# Permite listar y ver los partidos y registrar sus resultados. El registro
# delega en MatchResultProcessor, que se encarga de recalcular la tabla del
# grupo o de hacer avanzar la eliminatoria según corresponda.
class MatchesController < ApplicationController
  before_action :set_match, only: %i[show edit update register_result]

  # GET /matches — lista de partidos, opcionalmente filtrada por fase.
  def index
    @matches = Match.includes(:home_team, :away_team, :group).ordered
    @matches = @matches.where(phase: params[:phase]) if params[:phase].present?
  end

  # GET /matches/:id
  def show; end

  # GET /matches/:id/edit — formulario para registrar el resultado.
  def edit; end

  # PATCH /matches/:id — alias de register_result (mismo comportamiento).
  def update
    register_result
  end

  # PATCH /matches/:id/register_result — registra goles y penales.
  def register_result
    MatchResultProcessor.new(@match).call(
      home_goals: result_params[:home_goals].to_i,
      away_goals: result_params[:away_goals].to_i,
      home_penalties: presence_int(result_params[:home_penalties]),
      away_penalties: presence_int(result_params[:away_penalties])
    )
    redirect_back fallback_location: matches_path,
                  notice: "Resultado registrado: #{@match}."
  rescue MatchResultProcessor::InvalidResultError, ActiveRecord::RecordInvalid => e
    redirect_to edit_match_path(@match), alert: e.message
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def result_params
    params.require(:match).permit(:home_goals, :away_goals, :home_penalties, :away_penalties)
  end

  # Convierte a entero sólo si hay valor; si viene vacío devuelve nil.
  def presence_int(value)
    value.present? ? value.to_i : nil
  end
end
