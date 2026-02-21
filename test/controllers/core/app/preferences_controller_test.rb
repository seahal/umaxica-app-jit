# frozen_string_literal: true

require "test_helper"

class Core::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "show action is defined" do
    controller = Core::App::PreferencesController.new
    assert_respond_to controller, :show
  end

  test "controller inherits from ApplicationController" do
    assert_operator Core::App::PreferencesController, :<, Core::App::ApplicationController
  end
end
