# frozen_string_literal: true

require "application_system_test_case"

module App
  class HealthsTest < ApplicationSystemTestCase
     test "visiting the root of google registration index" do
      visit new_www_app_registration_url
      assert_selector "h1", text: "App::Registrations"
    end
  end
end
