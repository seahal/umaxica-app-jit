# == Schema Information
#
# Table name: app_preference_colortheme_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = AppPreferenceColorthemeOption.create!(id: "TEST_App_Colortheme")
    assert_not_nil option.id
  end

  test "has many app_preference_colorthemes" do
    option = AppPreferenceColorthemeOption.create!(id: "TEST_App_Colortheme")
    preference = AppPreference.create!
    colortheme = AppPreferenceColortheme.create!(preference: preference, option: option)
    assert_includes option.app_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = AppPreferenceColorthemeOption.create!(id: "TEST_App_Colortheme")
    preference = AppPreference.create!
    AppPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
