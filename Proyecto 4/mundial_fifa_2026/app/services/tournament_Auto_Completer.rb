# Servicio auxiliar para revisión/demo.
# Autocompleta el torneo completo desde el estado actual

class TournamentAutoCompleter
  def call
    generated_group_matches = generate_group_matches_if_needed
    completed_group_matches = complete_pending_group_matches

    # Por si la fase de grupos ya estaba completa pero el cuadro aún no existía.
    AutoBracketService.new.call

    completed_knockout_matches = complete_pending_knockout_matches

    {
      generated_group_matches: generated_group_matches,
      completed_group_matches: completed_group_matches,
      completed_knockout_matches: completed_knockout_matches,
      total_completed: completed_group_matches + completed_knockout_matches
    }
  end

  private

  def generate_group_matches_if_needed
    return 0 if Match.group_stage.exists?

    GroupFixtureGenerator.new.call
  end

  def complete_pending_group_matches
    completed = 0

    Match.group_stage.pending.ordered.each_with_index do |match, index|
      # Resultados determinísticos para que no sean completamente aleatorios.
      home_goals = (match.home_team.id + index) % 4
      away_goals = (match.away_team.id + index + 1) % 4

      MatchResultProcessor.new(match).call(
        home_goals: home_goals,
        away_goals: away_goals
      )

      completed += 1
    end

    completed
  end

  def complete_pending_knockout_matches
    completed = 0

    loop do
      pending_matches = Match.knockout
                             .pending
                             .includes(:home_team, :away_team)
                             .ordered
                             .select { |match| match.home_team.present? && match.away_team.present? }

      break if pending_matches.empty?

      pending_matches.each do |match|
        complete_knockout_match(match)
        completed += 1
      end
    end

    completed
  end

  def complete_knockout_match(match)
    # En eliminatoria evitamos empate para que avance siempre sin pedir penales.
    # La lógica de penales sigue existiendo para uso manual.
    if match.home_team.id.even?
      home_goals = 2
      away_goals = 1
    else
      home_goals = 1
      away_goals = 2
    end

    MatchResultProcessor.new(match).call(
      home_goals: home_goals,
      away_goals: away_goals
    )
  end
end