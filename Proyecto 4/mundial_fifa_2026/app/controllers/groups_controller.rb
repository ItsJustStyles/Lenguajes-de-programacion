# Controlador CRUD de los grupos del torneo (A a la L).
#
# Cumple el requisito 2 del enunciado: crear y administrar los 12 grupos.
class GroupsController < ApplicationController
  before_action :set_group, only: %i[show edit update destroy]

  # GET /groups — lista de grupos con su tabla de posiciones.
  def index
    @groups = Group.all
  end

  # GET /groups/:id — detalle de un grupo y sus selecciones.
  def show; end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/:id/edit
  def edit; end

  # POST /groups
  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group, notice: "Grupo creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/:id
  def update
    if @group.update(group_params)
      redirect_to @group, notice: "Grupo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    @group.destroy
    redirect_to groups_path, notice: "Grupo eliminado.", status: :see_other
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  # Sólo se permite asignar el nombre del grupo desde el formulario.
  def group_params
    params.require(:group).permit(:name)
  end
end
