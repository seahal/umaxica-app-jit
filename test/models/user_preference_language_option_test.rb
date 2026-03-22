# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_language_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "name returns ja for JA id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: UserPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: UserPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for unknown id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: 999)

    assert_nil option.name
  end
end
