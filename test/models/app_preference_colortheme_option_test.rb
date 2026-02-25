# typed: false
# == Schema Information
#
# Table name: app_preference_colortheme_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NEYO)
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
end
