# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::Com::PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "show action is defined" do
    controller = Core::Com::PreferencesController.new

    assert_respond_to controller, :show
  end

  test "controller is a subclass of ApplicationController" do
    assert_includes Core::Com::PreferencesController.ancestors, Core::Com::ApplicationController
  end
end
