# frozen_string_literal: true

require "test_helper"

module Api::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "inherits from ActionController::API" do
      assert_includes ApplicationController.ancestors, ActionController::API
    end

    test "includes RateLimit concern" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
    end
  end
end
