# Datos iniciales del torneo: los 12 grupos (A a la L) y 48 selecciones.
#
# Ejecutar con:  bin/rails db:seed
#
# El seed es idempotente: usa find_or_create_by, de modo que volver a correrlo
# no genera duplicados.

# Nombres de los 12 grupos del Mundial.
GROUP_NAMES = %w[A B C D E F G H I J K L].freeze

# 48 selecciones distribuidas en 12 grupos de 4 (4 países por grupo).
TEAMS_BY_GROUP = {
  "A" => ["México", "Canadá", "Marruecos", "Croacia"],
  "B" => ["Estados Unidos", "Gales", "Senegal", "Catar"],
  "C" => ["Argentina", "Polonia", "Australia", "Arabia Saudita"],
  "D" => ["Francia", "Dinamarca", "Túnez", "Perú"],
  "E" => ["España", "Alemania", "Japón", "Costa Rica"],
  "F" => ["Brasil", "Suiza", "Camerún", "Serbia"],
  "G" => ["Bélgica", "Turquía", "Corea del Sur", "Ghana"],
  "H" => ["Portugal", "Uruguay", "Ecuador", "Irán"],
  "I" => ["Inglaterra", "Países Bajos", "Nigeria", "Egipto"],
  "J" => ["Italia", "Colombia", "Costa de Marfil", "Nueva Zelanda"],
  "K" => ["Escocia", "Chile", "Argelia", "Panamá"],
  "L" => ["Noruega", "Suecia", "Sudáfrica", "Jamaica"]
}.freeze

puts "Creando grupos..."
groups = GROUP_NAMES.index_with do |name|
  Group.find_or_create_by!(name: name)
end
puts "  #{Group.count} grupos en la base de datos."

puts "Creando selecciones..."
TEAMS_BY_GROUP.each do |group_name, team_names|
  group = groups[group_name]
  team_names.each do |team_name|
    Team.find_or_create_by!(name: team_name) do |team|
      team.group = group
    end
  end
end
puts "  #{Team.count} selecciones en la base de datos."

puts "Seed completado."
