Rails.application.routes.draw do
  root 'party_loot_splitter#calculator'

  post 'party_loot_splitter/result'
end
