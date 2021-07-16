class PartyLootSplitterController < ApplicationController
  def calculator
    @split_options = SplitCalculator::SPLIT_LOGIC.map { |element| [element[:message], element[:key]] }
  end

  def result
    split_calculator = SplitCalculator.new(params[:split_logic], params[:party_hunt_log])

    split_calculator_policy = SplitCalculatorPolicy.new(split_calculator)

    @data = if split_calculator_policy.can_perform_split?
              split_calculator.calculate
            else
              split_calculator_policy.humanize_errors
            end
  rescue StandardError => _e
    @data = { errors: ['Errors while parsing input or calculating the result.'] }
  end
end
