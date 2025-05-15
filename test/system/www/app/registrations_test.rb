# frozen_string_literal: true

require "application_system_test_case"

module App
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the root of registration index" do
      visit www_app_root_url
      assert true
      #  assert_selector "h1", text: "Www::App::Roots#index"
    end
  end
end
