# == Schema Information
#
# Table name: org_preference_colortheme_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceColorthemeOption.create!
    assert_not_nil option.id
  end

  test "has many org_preference_colorthemes" do
    option = OrgPreferenceColorthemeOption.create!
    preference = OrgPreference.create!
    colortheme = OrgPreferenceColortheme.create!(preference: preference, option: option)
    assert_includes option.org_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceColorthemeOption.create!
    preference = OrgPreference.create!
    OrgPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
