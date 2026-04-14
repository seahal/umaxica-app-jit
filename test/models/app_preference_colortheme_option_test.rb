# typed: false
# == Schema Information
#
# Table name: app_preference_colortheme_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = AppPreferenceColorthemeOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many app_preference_colorthemes" do
    option = AppPreferenceColorthemeOption.create!(id: 99)
    preference = AppPreference.create!
    colortheme = AppPreferenceColortheme.create!(preference: preference, option: option)

    assert_includes option.app_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceColorthemeOption.create!(id: 99)
    preference = AppPreference.create!
    AppPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "returns light for LIGHT id" do
    option = AppPreferenceColorthemeOption.new(id: AppPreferenceColorthemeOption::LIGHT)

    assert_equal "light", option.name
  end

  test "returns dark for DARK id" do
    option = AppPreferenceColorthemeOption.new(id: AppPreferenceColorthemeOption::DARK)

    assert_equal "dark", option.name
  end

  test "returns system for SYSTEM id" do
    option = AppPreferenceColorthemeOption.new(id: AppPreferenceColorthemeOption::SYSTEM)

    assert_equal "system", option.name
  end

  test "returns nil for unknown id" do
    option = AppPreferenceColorthemeOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2, 3], AppPreferenceColorthemeOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    AppPreferenceColorthemeOption.where(id: AppPreferenceColorthemeOption::DEFAULTS).destroy_all

    AppPreferenceColorthemeOption.ensure_defaults!

    assert AppPreferenceColorthemeOption.exists?(id: AppPreferenceColorthemeOption::LIGHT)
    assert AppPreferenceColorthemeOption.exists?(id: AppPreferenceColorthemeOption::DARK)
    assert AppPreferenceColorthemeOption.exists?(id: AppPreferenceColorthemeOption::SYSTEM)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    AppPreferenceColorthemeOption.ensure_defaults!
    initial_count = AppPreferenceColorthemeOption.count

    AppPreferenceColorthemeOption.ensure_defaults!

    assert_equal initial_count, AppPreferenceColorthemeOption.count
  end
end
