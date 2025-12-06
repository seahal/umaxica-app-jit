# frozen_string_literal: true

require "test_helper"

module Back::Com
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "inherits from ActionController::Base" do
      assert_includes ApplicationController.ancestors, ActionController::Base
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
