# Migración para la tabla de partidos (matches).
#
# Un partido representa un encuentro entre dos selecciones, tanto en la fase
# de grupos como en la fase de eliminación directa. Por eso varios campos son
# opcionales: en la fase eliminatoria un partido puede existir antes de
# conocerse los equipos (TBD) y el grupo sólo aplica a la fase de grupos.
class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      # Fase del torneo (enum en el modelo): group, round_of_32, round_of_16,
      # quarter_final, semi_final, third_place, final.
      t.integer :phase, null: false, default: 0
      # Estado del partido (enum en el modelo): pending, completed.
      t.integer :status, null: false, default: 0
      # Etiqueta descriptiva opcional (ej. "Final", "Semifinal 1").
      t.string :round
      # Número de orden del partido dentro de su fase, útil para armar el cuadro.
      t.integer :match_number

      # Equipos local y visitante. Ambos referencian la tabla "teams" y son
      # opcionales porque en eliminatorias el cruce puede estar por definirse.
      t.references :home_team, null: true, foreign_key: { to_table: :teams }
      t.references :away_team, null: true, foreign_key: { to_table: :teams }

      # Goles del tiempo reglamentario. Nulos mientras el partido no se juega.
      t.integer :home_goals
      t.integer :away_goals

      # Goles en la tanda de penales (sólo eliminatoria y sólo si hay empate).
      t.integer :home_penalties
      t.integer :away_penalties

      # Grupo al que pertenece el partido. Sólo aplica a la fase de grupos,
      # por eso es opcional.
      t.references :group, null: true, foreign_key: true

      t.timestamps
    end
  end
end
