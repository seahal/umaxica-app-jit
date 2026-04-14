# typed: false
# == Schema Information
#
# Table name: com_preference_language_options
# Database name: commerce
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceLanguageOptionTest < ActiveSupport::TestCase
  setup do
    ComPreferenceStatus.find_or_create_by!(id: ComPreferenceStatus::NOTHING)
  end

  test "can be created" do
    option = ComPreferenceLanguageOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many com_preference_languages" do
    option = ComPreferenceLanguageOption.create!(id: 99)
    preference = ComPreference.create!
    language = ComPreferenceLanguage.create!(preference: preference, option: option)

    assert_includes option.com_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceLanguageOption.create!(id: 99)
    preference = ComPreference.create!
    ComPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns ja for JA id" do
    option = ComPreferenceLanguageOption.find_or_create_by!(id: ComPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = ComPreferenceLanguageOption.find_or_create_by!(id: ComPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for unknown id" do
    option = ComPreferenceLanguageOption.find_or_create_by!(id: 999)

    assert_nil option.name
  end

  test "DEFAULTS contains all expected values" do
    assert_equal [1, 2], ComPreferenceLanguageOption::DEFAULTS
  end

  test "ensure_defaults! creates missing records" do
    ComPreferenceLanguageOption.where(id: ComPreferenceLanguageOption::DEFAULTS).destroy_all

    ComPreferenceLanguageOption.ensure_defaults!

    assert ComPreferenceLanguageOption.exists?(id: ComPreferenceLanguageOption::JA)
    assert ComPreferenceLanguageOption.exists?(id: ComPreferenceLanguageOption::EN)
  end

  test "ensure_defaults! does nothing when all defaults exist" do
    ComPreferenceLanguageOption.ensure_defaults!
    initial_count = ComPreferenceLanguageOption.count

    ComPreferenceLanguageOption.ensure_defaults!

    assert_equal initial_count, ComPreferenceLanguageOption.count
  end
end
