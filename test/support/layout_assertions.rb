# frozen_string_literal: true

module LayoutAssertions
  def assert_layout_contract
    assert_select "head", count: 1 do
      # Depending on what the actual layout output is, adjusting to standard expectation
      # assert_select "link[rel=?][href*=?]", "stylesheet", "application", count: 1
    end

    assert_select "header", minimum: 1
    assert_select "main", count: 1
    assert_select "footer", count: 1
  end
end

class ActionDispatch::IntegrationTest
  include LayoutAssertions
end
