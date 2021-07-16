class PartyLootSplitterController < ApplicationController
  def calculator
  end

  def result
    @transfers = SplitCalculator.new(params[:party_hunt_log]).obtain_transfers
  end
end
