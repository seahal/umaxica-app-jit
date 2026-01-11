# frozen_string_literal: true

require "test_helper"

module Core::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
      assert_includes controller.class, Preference::Main
      assert_includes controller.class, Preference::Regional
    end
  end
end
