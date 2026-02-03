# == Schema Information
#
# Table name: org_preference_colortheme_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  setup do
    OrgPreferenceStatus.find_or_create_by!(id: OrgPreferenceStatus::NEYO)
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
end
