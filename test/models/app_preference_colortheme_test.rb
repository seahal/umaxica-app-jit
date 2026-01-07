# == Schema Information
#
# Table name: app_preference_colorthemes
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_app_preference_colorthemes_on_option_id      (option_id)
#  index_app_preference_colorthemes_on_preference_id  (preference_id)
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
    assert_includes colortheme.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    colortheme = AppPreferenceColortheme.create!(preference: @preference)
    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
  end

  test "can be created with option" do
    option = AppPreferenceColorthemeOption.create!(id: "TEST_App_Colortheme")
    colortheme = AppPreferenceColortheme.create!(preference: @preference, option: option)
    assert_equal option, colortheme.option
  end

  test "can be created without option" do
    colortheme = AppPreferenceColortheme.create!(preference: @preference)
    assert_nil colortheme.option
  end

  test "validates uniqueness of preference" do
    AppPreferenceColortheme.create!(preference: @preference)
    duplicate_colortheme = AppPreferenceColortheme.new(preference: @preference)
    assert_not duplicate_colortheme.valid?
    assert_includes duplicate_colortheme.errors[:preference_id], "はすでに存在します"
  end
end
