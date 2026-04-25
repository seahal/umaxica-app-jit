# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceCoreTestController < ::Jit::Foundation::Base::App::ApplicationController
  include ::Preference::Core

  attr_accessor :test_preferences

  def initialize(*)
    super
    @test_preferences = nil
  end

  def controller_path
    "sign/org/preferences"
  end

  def test_load_or_refresh_preference_child(child_type)
    @preferences = @test_preferences
    load_or_refresh_preference_child(child_type, {})
  end
end

class PreferenceCoreNilGuardTest < ActiveSupport::TestCase
  test "load_or_refresh_preference_child returns nil when preferences is nil" do
    controller = PreferenceCoreTestController.new
    controller.test_preferences = nil

    result = controller.test_load_or_refresh_preference_child("Language")

    assert_nil result, "should return nil when @preferences is nil"
  end

  test "load_or_refresh_preference_child returns nil when preferences is blank" do
    controller = PreferenceCoreTestController.new
    controller.test_preferences = nil

    result = controller.test_load_or_refresh_preference_child("Timezone")

    assert_nil result, "should return nil when @preferences is blank"
  end
end
