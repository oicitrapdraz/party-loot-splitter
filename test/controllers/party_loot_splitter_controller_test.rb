require "test_helper"

class PartyLootSplitterControllerTest < ActionDispatch::IntegrationTest
  test "should get calculator" do
    get party_loot_splitter_calculator_url
    assert_response :success
  end
end
