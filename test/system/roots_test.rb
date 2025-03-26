# frozen_string_literal: true

require "application_system_test_case"

class RootsTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit dev_root_url
    assert true
  end
end
