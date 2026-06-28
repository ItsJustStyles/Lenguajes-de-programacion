# Controlador CRUD de las selecciones participantes.
#
# Cumple el requisito 1 del enunciado: registrar selecciones con su país y
# grupo. Las estadísticas (puntos, goles, etc.) no se editan a mano: las
# calcula el sistema a partir de los resultados.
class TeamsController < ApplicationController
  before_action :set_team, only: %i[show edit update destroy]
  before_action :load_groups, only: %i[new edit create update]

  # GET /teams — todas las selecciones, agrupadas por grupo en la vista.
  def index
    @teams = Team.includes(:group).order("groups.name", :name)
  end

  # GET /teams/:id
  def show; end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/:id/edit
  def edit; end

  # POST /teams
  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to @team, notice: "Selección registrada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /teams/:id
  def update
    if @team.update(team_params)
      redirect_to @team, notice: "Selección actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /teams/:id
  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Selección eliminada.", status: :see_other
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def load_groups
    @groups = Group.all
  end

  # Sólo se permiten el nombre del país y el grupo asignado.
  def team_params
    params.require(:team).permit(:name, :group_id)
  end
end
