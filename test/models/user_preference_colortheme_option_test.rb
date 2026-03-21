# typed: false
# frozen_string_literal: true

require "test_helper"

class UserPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "returns light for LIGHT id" do
    option = UserPreferenceColorthemeOption.new(id: UserPreferenceColorthemeOption::LIGHT)
    assert_equal "light", option.name
  end

  test "returns dark for DARK id" do
    option = UserPreferenceColorthemeOption.new(id: UserPreferenceColorthemeOption::DARK)
    assert_equal "dark", option.name
  end

  test "returns system for SYSTEM id" do
    option = UserPreferenceColorthemeOption.new(id: UserPreferenceColorthemeOption::SYSTEM)
    assert_equal "system", option.name
  end

  test "returns nil for NOTHING id" do
    option = UserPreferenceColorthemeOption.new(id: UserPreferenceColorthemeOption::NOTHING)
    assert_nil option.name
  end

  test "returns nil for unknown id" do
    option = UserPreferenceColorthemeOption.new(id: 999)
    assert_nil option.name
  end

  test "ensure_defaults! creates missing records" do
    UserPreferenceColorthemeOption.where(id: UserPreferenceColorthemeOption::DEFAULTS).destroy_all

    UserPreferenceColorthemeOption.ensure_defaults!

    assert UserPreferenceColorthemeOption.exists?(id: UserPreferenceColorthemeOption::NOTHING)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    UserPreferenceColorthemeOption.ensure_defaults!
    initial_count = UserPreferenceColorthemeOption.count

    UserPreferenceColorthemeOption.ensure_defaults!

    assert_equal initial_count, UserPreferenceColorthemeOption.count
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [0, 1, 2, 3], UserPreferenceColorthemeOption::DEFAULTS
  end

  test "has_many association exists" do
    option = UserPreferenceColorthemeOption.new(id: 1)
    assert_respond_to option, :user_preference_colorthemes
  end
end
