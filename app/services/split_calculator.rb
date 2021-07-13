class SplitCalculator
  attr_reader :party_hunt_log, :number_of_players

  def initialize(party_hunt_log)
    @party_hunt_log = party_hunt_log
  end

  def obtain_transfers
    lines = party_hunt_log.split(/\r?\n\t?/)

    duration = lines.second.gsub('Session ', '')

    loot_type = lines[2]

    balance = lines[5].gsub('Balance ', '').tr(',', '').to_i

    players = parse_players_input(lines)

    balance_per_player = (balance / players.count.to_f).floor

    match_balances(balance, players)
  end

  private

  def parse_players_input(lines)
    players = []

    data_grouped_by_players = lines[6..-1].each_slice(6)

    data_grouped_by_players.to_a.each do |raw_player_data|
      player = { }

      player[:name] = raw_player_data.first.gsub(' (Leader)', '')
      player[:balance] = raw_player_data.fourth.gsub(/Balance:? /, '').tr(',', '').to_i

      players.append player
    end

    players
  end

  def match_balances(balance, players)
    transfers = []

    valid_split = [balance/ players.count + 1] * (balance% players.count) + [balance/ players.count] * (players.count - balance% players.count)

    players.each_with_index do |first_player, first_index|
      if first_player[:balance] > valid_split[first_index]
        players.each_with_index do |second_player, second_index|
          if second_player[:balance] < valid_split[second_index]
            first_player_surplus = first_player[:balance] - valid_split[first_index]
            second_player_deficit = valid_split[second_index] - second_player[:balance]
            transfer_amount = [first_player_surplus, second_player_deficit].min

            transfers.append(from: first_player[:name], to: second_player[:name], amount: transfer_amount)
            first_player[:balance] -= transfer_amount
            second_player[:balance] += transfer_amount
          end
        end
      end
    end

    transfers
  end
end