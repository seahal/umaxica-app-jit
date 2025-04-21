# frozen_string_literal: true

require "application_system_test_case"

module App
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the index" do
      visit www_app_health_url
      assert_text "OK"
    end
  end
end
