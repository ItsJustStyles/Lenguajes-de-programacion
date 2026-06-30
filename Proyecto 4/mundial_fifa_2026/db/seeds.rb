Match.delete_all
Team.delete_all
Group.delete_all

groups_data = {
  "A" => ["México", "Sudáfrica", "Corea del Sur", "Chequia"],
  "B" => ["Canadá", "Bosnia y Herzegovina", "Catar", "Suiza"],
  "C" => ["Brasil", "Marruecos", "Haití", "Escocia"],
  "D" => ["Estados Unidos", "Paraguay", "Australia", "Turquía"],
  "E" => ["Alemania", "Curazao", "Costa de Marfil", "Ecuador"],
  "F" => ["Países Bajos", "Japón", "Suecia", "Túnez"],
  "G" => ["Bélgica", "Egipto", "Irán", "Nueva Zelanda"],
  "H" => ["España", "Cabo Verde", "Arabia Saudita", "Uruguay"],
  "I" => ["Francia", "Senegal", "Irak", "Noruega"],
  "J" => ["Argentina", "Argelia", "Austria", "Jordania"],
  "K" => ["Portugal", "RD Congo", "Uzbekistán", "Colombia"],
  "L" => ["Inglaterra", "Croacia", "Ghana", "Panamá"]
}

puts "Creando grupos y selecciones oficiales..."

groups_data.each do |group_name, team_names|
  group = Group.create!(name: group_name)

  team_names.each do |team_name|
    Team.create!(name: team_name, group: group)
  end
end

puts "Seed completado."
puts "Grupos: #{Group.count}"
puts "Selecciones: #{Team.count}"
puts "Partidos: #{Match.count}"