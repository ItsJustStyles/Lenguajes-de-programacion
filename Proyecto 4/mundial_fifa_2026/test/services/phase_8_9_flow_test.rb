require "test_helper"

# Pruebas de integración de servicios para las fases 8 y 9.
#
# No dependen de fixtures: construyen un mundial mínimo completo con 12 grupos,
# 48 selecciones, 72 partidos de grupos y luego simulan la eliminatoria.
class Phase89FlowTest < ActiveSupport::TestCase
  GROUP_NAMES = %w[A B C D E F G H I J K L].freeze

  setup do
    Match.delete_all
    Team.delete_all
    Group.delete_all

    GROUP_NAMES.each do |group_name|
      group = Group.create!(name: group_name)
      4.times do |index|
        Team.create!(name: "#{group_name}#{index + 1}", group: group)
      end
    end

    GroupFixtureGenerator.new.call
  end

  test "al completar el ultimo partido de grupos se generan automaticamente los dieciseisavos" do
    complete_group_stage!

    assert_equal 72, Match.group_stage.completed.count
    assert_equal 32, Team.qualified.count
    assert_equal 16, Match.round_of_32.pending.count
    assert Match.round_of_32.all? { |match| match.home_team.present? && match.away_team.present? }
  end

  test "un empate de eliminatoria requiere penales con ganador" do
    complete_group_stage!
    match = Match.round_of_32.ordered.first

    assert_raises(MatchResultProcessor::InvalidResultError) do
      MatchResultProcessor.new(match).call(home_goals: 1, away_goals: 1)
    end

    assert_equal "pending", match.reload.status

    MatchResultProcessor.new(match).call(
      home_goals: 1,
      away_goals: 1,
      home_penalties: 5,
      away_penalties: 4
    )

    assert_equal "completed", match.reload.status
    assert_equal match.home_team, match.winner
  end

  test "la eliminatoria avanza hasta final, tercer lugar y podio" do
    complete_group_stage!

    complete_phase!(:round_of_32)
    assert_equal 8, Match.round_of_16.pending.count

    complete_phase!(:round_of_16)
    assert_equal 4, Match.quarter_final.pending.count

    complete_phase!(:quarter_final)
    assert_equal 2, Match.semi_final.pending.count

    complete_phase!(:semi_final)
    assert_equal 1, Match.final.pending.count
    assert_equal 1, Match.third_place.pending.count

    complete_phase!(:third_place)
    complete_phase!(:final)

    podium = FinalResultsService.new.call
    assert podium[:finished]
    assert podium[:champion].present?
    assert podium[:runner_up].present?
    assert podium[:third_place].present?
    assert_not_equal podium[:champion], podium[:runner_up]
  end

  private

  def complete_group_stage!
    Match.group_stage.ordered.each_with_index do |match, index|
      home_goals = index.even? ? 2 : 1
      away_goals = index.even? ? 0 : 3
      MatchResultProcessor.new(match).call(home_goals: home_goals, away_goals: away_goals)
    end
  end

  def complete_phase!(phase)
    Match.where(phase: phase).ordered.each do |match|
      MatchResultProcessor.new(match).call(home_goals: 2, away_goals: 1)
    end
  end
end
