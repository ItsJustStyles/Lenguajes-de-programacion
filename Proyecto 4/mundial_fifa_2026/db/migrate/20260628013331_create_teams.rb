# Migración para la tabla de selecciones (teams).
#
# Cada selección pertenece a un grupo y mantiene sus estadísticas acumuladas
# de la fase de grupos. Las estadísticas inician en cero y se recalculan
# automáticamente a medida que se registran resultados.
class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      # Grupo asignado. Opcional a nivel de BD para permitir altas flexibles,
      # pero validado como requerido en el modelo.
      t.references :group, null: true, foreign_key: true

      # Estadísticas de la fase de grupos.
      t.integer :points, null: false, default: 0           # Puntos (3 por victoria, 1 por empate)
      t.integer :goals_for, null: false, default: 0        # Goles a favor
      t.integer :goals_against, null: false, default: 0    # Goles en contra
      t.integer :goal_difference, null: false, default: 0  # Diferencia de goles
      t.integer :matches_played, null: false, default: 0   # Partidos jugados
      t.integer :wins, null: false, default: 0             # Victorias
      t.integer :draws, null: false, default: 0            # Empates
      t.integer :losses, null: false, default: 0           # Derrotas

      # Posición dentro del grupo (1 a 4), calculada por el StandingsCalculator.
      t.integer :group_position
      # Banderas de avance en el torneo.
      t.boolean :qualified, null: false, default: false    # Clasificó a eliminatoria
      t.boolean :eliminated, null: false, default: false   # Quedó eliminado

      t.timestamps
    end
  end
end
