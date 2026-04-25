# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_colorthemes
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
#  index_user_preference_colorthemes_on_option_id      (option_id)
#  index_user_preference_colorthemes_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_user_preference_colorthemes_on_option_id      (option_id => user_preference_colortheme_options.id)
#  fk_user_preference_colorthemes_on_preference_id  (preference_id => user_preferences.id)
#

require "test_helper"

class UserPreferenceColorthemeTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    @preference = UserPreference.create!(user: @user)
    @option = UserPreferenceColorthemeOption.find_or_create_by!(id: UserPreferenceColorthemeOption::SYSTEM)
  end

  test "should be valid with preference and option" do
    record = UserPreferenceColortheme.new(
      preference: @preference,
      option: @option,
    )

    assert_predicate record, :valid?
  end

  test "should require preference" do
    record = UserPreferenceColortheme.new(
      option: @option,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:preference]
  end

  test "preference_id must be unique" do
    UserPreferenceColortheme.create!(
      preference: @preference,
      option: @option,
    )

    duplicate = UserPreferenceColortheme.new(
      preference: @preference,
      option: @option,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:preference_id]
  end

  test "same option_id with different preference_id is allowed" do
    UserPreferenceColortheme.create!(
      preference: @preference,
      option: @option,
    )

    other_user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    other_preference = UserPreference.create!(user: other_user)

    different_preference = UserPreferenceColortheme.new(
      preference: other_preference,
      option: @option,
    )

    assert_predicate different_preference, :valid?
  end

  test "belongs to preference" do
    record = UserPreferenceColortheme.create!(
      preference: @preference,
      option: @option,
    )

    assert_equal @preference, record.preference
  end

  test "belongs to option" do
    record = UserPreferenceColortheme.create!(
      preference: @preference,
      option: @option,
    )

    assert_equal @option, record.option
  end

  test "sets default option_id before validation" do
    record = UserPreferenceColortheme.new(
      preference: @preference,
    )

    assert_predicate record, :valid?
    assert_equal UserPreferenceColorthemeOption::SYSTEM, record.option_id
  end
end
