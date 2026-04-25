# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_colortheme_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "returns light for LIGHT id" do
    option = StaffPreferenceColorthemeOption.new(id: StaffPreferenceColorthemeOption::LIGHT)

    assert_equal "light", option.name
  end

  test "returns dark for DARK id" do
    option = StaffPreferenceColorthemeOption.new(id: StaffPreferenceColorthemeOption::DARK)

    assert_equal "dark", option.name
  end

  test "returns system for SYSTEM id" do
    option = StaffPreferenceColorthemeOption.new(id: StaffPreferenceColorthemeOption::SYSTEM)

    assert_equal "system", option.name
  end

  test "returns nil for NOTHING id" do
    option = StaffPreferenceColorthemeOption.new(id: StaffPreferenceColorthemeOption::NOTHING)

    assert_nil option.name
  end

  test "returns nil for unknown id" do
    option = StaffPreferenceColorthemeOption.new(id: 999)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing records" do
    StaffPreferenceColorthemeOption.where(id: StaffPreferenceColorthemeOption::DEFAULTS).destroy_all

    StaffPreferenceColorthemeOption.ensure_defaults!

    assert StaffPreferenceColorthemeOption.exists?(id: StaffPreferenceColorthemeOption::NOTHING)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    StaffPreferenceColorthemeOption.ensure_defaults!
    initial_count = StaffPreferenceColorthemeOption.count

    StaffPreferenceColorthemeOption.ensure_defaults!

    assert_equal initial_count, StaffPreferenceColorthemeOption.count
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2, 3], StaffPreferenceColorthemeOption::DEFAULTS
  end

  test "has_many association exists" do
    option = StaffPreferenceColorthemeOption.new(id: 1)

    assert_respond_to option, :staff_preference_colorthemes
  end
end
