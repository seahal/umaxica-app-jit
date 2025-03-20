# frozen_string_literal: true

require "application_system_test_case"

module Org
  class HealthsTest < ApplicationSystemTestCase
    test "visiting the index" do
      visit www_org_health_url

      assert_selector "h1", text: "ok"
    end
  end
end
