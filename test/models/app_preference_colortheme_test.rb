# typed: false
# == Schema Information
#
# Table name: app_preference_colorthemes
# Database name: principal
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_app_preference_colorthemes_on_option_id      (option_id)
#  index_app_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_app_preference_colorthemes_on_option_id  (option_id => app_preference_colortheme_options.id)
#  fk_rails_...                                (preference_id => app_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceColorthemeTest < ActiveSupport::TestCase
  setup do
    AppPreferenceStatus.find_or_create_by!(id: AppPreferenceStatus::NOTHING)
    @preference = AppPreference.create!(status_id: AppPreferenceStatus::NOTHING)
  end

  test "belongs to preference" do
    colortheme = AppPreferenceColortheme.new

    assert_not colortheme.valid?
    assert_not_empty colortheme.errors[:preference]
  end

  test "can be created with preference and option" do
    option = app_preference_colortheme_options(:light)
    colortheme = AppPreferenceColortheme.create!(preference: @preference, option: option)

    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
    assert_equal option, colortheme.option
  end

  test "sets default option_id on create" do
    colortheme = AppPreferenceColortheme.create!(preference: @preference)

    assert_equal AppPreferenceColorthemeOption::SYSTEM, colortheme.option_id
  end

  test "validates uniqueness of preference" do
    option = app_preference_colortheme_options(:light)
    AppPreferenceColortheme.create!(preference: @preference, option: option)
    duplicate_colortheme = AppPreferenceColortheme.new(preference: @preference, option: option)

    assert_not duplicate_colortheme.valid?
    assert_not_empty duplicate_colortheme.errors[:preference_id]
  end

  test "AppPreferenceColorthemeOption accepts numeric ids" do
    option = AppPreferenceColorthemeOption.create!(id: 99)

    assert_predicate option, :persisted?
    colortheme = AppPreferenceColortheme.create!(preference: @preference, option_id: 99)

    assert_equal option, colortheme.option
  end
end
