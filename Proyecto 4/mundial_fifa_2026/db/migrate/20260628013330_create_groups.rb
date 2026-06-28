# Migración para la tabla de grupos (groups).
#
# El torneo cuenta con 12 grupos identificados de la A a la L. El nombre es
# único para evitar grupos duplicados.
class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :groups, :name, unique: true
  end
end
