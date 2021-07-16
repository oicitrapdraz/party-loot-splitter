class SplitCalculatorPolicy
  attr_reader :split_calculator

  def initialize(split_calculator)
    @split_calculator = split_calculator
  end

  def can_perform_split?
    players_count_is_positive && split_logic_is_not_damage_and_balance_positive
  end

  def humanize_errors
    message = { errors: [] }

    message[:errors].append('Players not found!') unless players_count_is_positive
    unless split_logic_is_not_damage_and_balance_positive
      message[:errors].append('If split logic is damage, balance must be positive!')
    end

    message
  end

  private

  def players_count_is_positive
    split_calculator.players.count.positive?
  end

  def split_logic_is_not_damage_and_balance_positive
    split_calculator.split_logic == 'normal' || (split_calculator.split_logic == 'damage' && split_calculator.balance.positive?)
  end
end
