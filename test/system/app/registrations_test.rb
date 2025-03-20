# frozen_string_literal: true

require "application_system_test_case"

module Net
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the root of registration index" do
      visit new_www_app_registration_url
      assert_selector "h1", text: "Net::Registrations"
    end
  end
end
