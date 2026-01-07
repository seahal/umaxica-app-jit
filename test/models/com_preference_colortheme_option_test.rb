# == Schema Information
#
# Table name: com_preference_colortheme_options
#
#  id :uuid             not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceColorthemeOption.create!
    assert_not_nil option.id
  end

  test "has many com_preference_colorthemes" do
    option = ComPreferenceColorthemeOption.create!
    preference = ComPreference.create!
    colortheme = ComPreferenceColortheme.create!(preference: preference, option: option)
    assert_includes option.com_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceColorthemeOption.create!
    preference = ComPreference.create!
    ComPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
