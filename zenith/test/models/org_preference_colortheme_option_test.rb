# typed: false
# == Schema Information
#
# Table name: org_preference_colortheme_options
# Database name: operator
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  setup do
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = OrgPreferenceColorthemeOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many org_preference_colorthemes" do
    option = OrgPreferenceColorthemeOption.create!(id: 99)
    preference = OrgPreference.create!
    colortheme = OrgPreferenceColortheme.create!(preference: preference, option: option)

    assert_includes option.org_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceColorthemeOption.create!(id: 99)
    preference = OrgPreference.create!
    OrgPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "accepts integer ids" do
    option = OrgPreferenceColorthemeOption.new(id: 123)

    assert_predicate option, :valid?
  end

  test "returns light for LIGHT id" do
    option = OrgPreferenceColorthemeOption.new(id: OrgPreferenceColorthemeOption::LIGHT)

    assert_equal "light", option.name
  end

  test "returns dark for DARK id" do
    option = OrgPreferenceColorthemeOption.new(id: OrgPreferenceColorthemeOption::DARK)

    assert_equal "dark", option.name
  end

  test "returns system for SYSTEM id" do
    option = OrgPreferenceColorthemeOption.new(id: OrgPreferenceColorthemeOption::SYSTEM)

    assert_equal "system", option.name
  end

  test "returns nil for unknown id" do
    option = OrgPreferenceColorthemeOption.new(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2, 3], OrgPreferenceColorthemeOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    OrgPreferenceColorthemeOption.where(id: OrgPreferenceColorthemeOption::DEFAULTS).destroy_all

    OrgPreferenceColorthemeOption.ensure_defaults!

    assert OrgPreferenceColorthemeOption.exists?(id: OrgPreferenceColorthemeOption::LIGHT)
    assert OrgPreferenceColorthemeOption.exists?(id: OrgPreferenceColorthemeOption::DARK)
    assert OrgPreferenceColorthemeOption.exists?(id: OrgPreferenceColorthemeOption::SYSTEM)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    OrgPreferenceColorthemeOption.ensure_defaults!
    initial_count = OrgPreferenceColorthemeOption.count

    OrgPreferenceColorthemeOption.ensure_defaults!

    assert_equal initial_count, OrgPreferenceColorthemeOption.count
  end

  test "has_many association exists" do
    option = OrgPreferenceColorthemeOption.new(id: 1)

    assert_respond_to option, :org_preference_colorthemes
  end
end
