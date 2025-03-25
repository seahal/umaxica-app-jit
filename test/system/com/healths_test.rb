# frozen_string_literal: true

require "application_system_test_case"

module Com
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the index" do
      visit www_com_health_url
      assert_text "OK"
    end
  end
end
