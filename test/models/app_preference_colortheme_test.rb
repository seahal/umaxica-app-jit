# == Schema Information
#
# Table name: app_preference_colorthemes
# Database name: preference
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#  preference_id :uuid             not null
#
# Indexes
#
#  index_app_preference_colorthemes_on_option_id      (option_id)
#  index_app_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => app_preference_colortheme_options.id)
#  fk_rails_...  (preference_id => app_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceColorthemeTest < ActiveSupport::TestCase
  setup do
    @preference = AppPreference.create!
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
    assert_equal "system", colortheme.option_id
  end

  test "validates uniqueness of preference" do
    option = app_preference_colortheme_options(:light)
    AppPreferenceColortheme.create!(preference: @preference, option: option)
    duplicate_colortheme = AppPreferenceColortheme.new(preference: @preference, option: option)
    assert_not duplicate_colortheme.valid?
    assert_not_empty duplicate_colortheme.errors[:preference_id]
  end

  test "permits lowercase theme string as option_id and associates with valid option" do
    colortheme = AppPreferenceColortheme.create!(preference: @preference, option_id: "light")
    assert_equal "light", colortheme.option_id
    # "light" exists in fixtures and matches relaxed regex
    assert_equal app_preference_colortheme_options(:light), colortheme.option
  end

  test "AppPreferenceColorthemeOption accepts lowercase with relaxed regex" do
    option = AppPreferenceColorthemeOption.new(id: "dim")
    assert_predicate option, :valid?
  end

  test "AppPreferenceColorthemeOption rejects invalid characters" do
    option = AppPreferenceColorthemeOption.new(id: "Bad-Theme")
    assert_not option.valid?
    assert_includes option.errors[:id], "は不正な値です"
  end
end
