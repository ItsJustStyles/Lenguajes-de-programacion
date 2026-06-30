class GroupFixtureGenerator
  class GroupIncompleteError < StandardError; end

  # Orden real por grupo según el orden de equipos del sorteo.
  # Con 4 equipos por grupo, el patrón de cruces es:
  # Fecha 1: 1 vs 2, 3 vs 4
  # Fecha 2: 1 vs 3, 4 vs 2
  # Fecha 3: 4 vs 1, 2 vs 3
  #
  # El modelo actual no guarda fecha ni sede; por eso aquí se guardan los cruces
  # reales como partidos de fase de grupos.
  MATCHDAY_PATTERN = [
    [0, 1],
    [2, 3],
    [0, 2],
    [3, 1],
    [3, 0],
    [1, 2]
  ].freeze

  def initialize(group = nil)
    @groups = group ? [group] : Group.order(:name).to_a
  end

  def call
    validate_groups_are_complete!

    created = 0

    @groups.each do |group|
      created += generate_for(group)
    end

    created
  end

  private

  def validate_groups_are_complete!
    incomplete = @groups.select { |group| group.teams.count != Group::TEAMS_PER_GROUP }
    return if incomplete.empty?

    names = incomplete.map { |group| "Grupo #{group.name}" }.join(", ")

    raise GroupIncompleteError,
          "Todos los grupos deben tener #{Group::TEAMS_PER_GROUP} selecciones antes de generar partidos. Incompletos: #{names}."
  end

  def generate_for(group)
    return 0 if group.matches.exists?

    teams = group.teams.order(:id).to_a
    created = 0

    MATCHDAY_PATTERN.each_with_index do |(home_index, away_index), index|
      Match.create!(
        group: group,
        home_team: teams[home_index],
        away_team: teams[away_index],
        phase: :group_stage,
        status: :pending,
        match_number: index + 1
      )

      created += 1
    end

    created
  end
end