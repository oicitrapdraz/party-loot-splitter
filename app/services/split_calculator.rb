class SplitCalculator
  attr_reader :split_logic, :party_hunt_log, :number_of_players, :duration, :loot_type, :balance

  SPLIT_LOGIC = [{ message: 'Normal Split (equalize balances)', key: :normal },
                 { message: 'Weighted by Damage (prioritize those who did the most damage)', key: :damage }].freeze

  def initialize(split_logic, party_hunt_log)
    @split_logic = split_logic
    @party_hunt_log = party_hunt_log
  end

  def calculate
    lines = party_hunt_log.split(/\r?\n\t?/)

    set_basic_data(lines)

    players = parse_players_from_input(lines)

    balance_per_player = (balance / players.count.to_f).floor

    { number_of_players: number_of_players, duration: duration, loot_type: loot_type, balance: balance,
      transfers: match_balances(balance, players) }
  end

  private

  def set_basic_data(lines)
    @duration = lines.second.gsub('Session ', '')

    @loot_type = lines[2]

    @balance = lines[5].gsub('Balance ', '').tr(',', '').to_i
  end

  def parse_players_from_input(lines)
    players = []

    data_grouped_by_players = lines[6..-1].each_slice(6)

    @number_of_players = data_grouped_by_players.count

    data_grouped_by_players.to_a.each do |raw_player_data|
      player = {}

      player[:name] = raw_player_data.first.gsub(' (Leader)', '')
      player[:balance] = raw_player_data.fourth.gsub(/Balance:? /, '').tr(',', '').to_i
      player[:damage] = raw_player_data.fifth.gsub(/Damage:? /, '').tr(',', '').to_i

      players.append player
    end

    players
  end

  def match_balances(balance, players)
    transfers = []

    valid_split = if split_logic == 'normal'
                    [balance / players.count + 1] * (balance % players.count) + [balance / players.count] * (players.count - balance % players.count)
                  elsif split_logic == 'damage'
                    total_damage = players.map { |player| player[:damage] }.sum

                    players.map { |player| (player[:damage] / total_damage.to_f) * balance }
                  end

    players.each_with_index do |first_player, first_index|
      next unless first_player[:balance] > valid_split[first_index]

      players.each_with_index do |second_player, second_index|
        next unless second_player[:balance] < valid_split[second_index]

        first_player_surplus = first_player[:balance] - valid_split[first_index]
        second_player_deficit = valid_split[second_index] - second_player[:balance]
        transfer_amount = [first_player_surplus, second_player_deficit].min

        transfers.append(from: first_player[:name], to: second_player[:name], amount: transfer_amount)

        first_player[:balance] -= transfer_amount
        second_player[:balance] += transfer_amount
      end
    end

    transfers
  end
end
