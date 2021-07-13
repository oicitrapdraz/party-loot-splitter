class PartyLootSplitterController < ApplicationController
  def calculator
  end

  def perform_split
    transfers = SplitCalculator.new(params[:party_hunt_log]).obtain_transfers

    redirect_to party_loot_splitter_result_path(transfers: transfers)
  end

  def result
    byebug
  end
end
