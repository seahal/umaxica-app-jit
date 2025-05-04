# frozen_string_literal: true

require "application_system_test_case"

module App
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the root of apple registration index" do
      visit new_www_app_registration_apple_url
      assert_selector "h1", text: I18n.t("www.app.registration.apple.new.page_title")
    end
  end
end
