# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_behavior_levels
# Database name: behavior
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppContactBehaviorLevelTest < ActiveSupport::TestCase
  test "has correct constants" do
    assert_equal 0, AppContactBehaviorLevel::NOTHING
    assert_equal 1, AppContactBehaviorLevel::LEGACY_NOTHING
    assert_equal 2, AppContactBehaviorLevel::DEBUG
    assert_equal 3, AppContactBehaviorLevel::INFO
    assert_equal 4, AppContactBehaviorLevel::WARN
    assert_equal 5, AppContactBehaviorLevel::ERROR
  end

  test "can load nothing status from db" do
    status = AppContactBehaviorLevel.find(AppContactBehaviorLevel::NOTHING)

    assert_equal 0, status.id
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "AppContactBehaviorLevel.count" do
      AppContactBehaviorLevel.ensure_defaults!
    end
  end
end
