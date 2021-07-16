class PartyLootSplitterController < ApplicationController
  def calculator
    @split_options = SplitCalculator::SPLIT_LOGIC.map { |element| [element[:message], element[:key]] }
  end

  def result
    @data = SplitCalculator.new(params[:split_logic], params[:party_hunt_log]).calculate
  end
end
