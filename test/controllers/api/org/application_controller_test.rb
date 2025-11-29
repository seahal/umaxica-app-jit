# frozen_string_literal: true

require "test_helper"

module Api::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "inherits from ActionController::API" do
      assert ApplicationController.ancestors.include?(ActionController::API)
    end

    test "includes RateLimit concern" do
      controller = ApplicationController.new

      assert controller.class.include?(RateLimit)
    end
  end
end
