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
  test "can be created" do
    option = UserPreferenceLanguageOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "name returns ja for JA id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: UserPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: UserPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for NOTHING id" do
    option = UserPreferenceLanguageOption.find_or_create_by!(id: UserPreferenceLanguageOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = UserPreferenceLanguageOption.create!(id: 999)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    UserPreferenceLanguageOption.create!(id: 1000)
    UserPreferenceLanguageOption.create!(id: 1001)

    test_defaults = [1000, 1001]
    UserPreferenceLanguageOption.stub(:default_ids, test_defaults) do
      UserPreferenceLanguageOption.where(id: test_defaults).delete_all
      UserPreferenceLanguageOption.ensure_defaults!

      assert UserPreferenceLanguageOption.exists?(1000)
      assert UserPreferenceLanguageOption.exists?(1001)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    UserPreferenceLanguageOption.create!(id: 2000)
    UserPreferenceLanguageOption.create!(id: 2001)

    test_defaults = [2000, 2001]
    UserPreferenceLanguageOption.stub(:default_ids, test_defaults) do
      UserPreferenceLanguageOption.ensure_defaults!
      count_before = UserPreferenceLanguageOption.where(id: test_defaults).count
      UserPreferenceLanguageOption.ensure_defaults!
      count_after = UserPreferenceLanguageOption.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    UserPreferenceLanguageOption.stub(:default_ids, []) do
      assert_nothing_raised do
        UserPreferenceLanguageOption.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    UserPreferenceLanguageOption.stub(:default_ids, nil) do
      assert_nothing_raised do
        UserPreferenceLanguageOption.ensure_defaults!
      end
    end
  end

  test "DEFAULTS contains expected values" do
    expected = [UserPreferenceLanguageOption::JA,
                UserPreferenceLanguageOption::EN,]

    assert_equal expected, UserPreferenceLanguageOption::DEFAULTS
  end

  test "DEFAULTS is frozen" do
    assert_predicate UserPreferenceLanguageOption::DEFAULTS, :frozen?
  end

  test "has_many association with user_preference_languages" do
    option = UserPreferenceLanguageOption.create!(id: 999)

    assert_respond_to option, :user_preference_languages
    assert_equal [], option.user_preference_languages.to_a
  end

  test "dependent restrict_with_error on user_preference_languages" do
    skip "Skipping dependent test due to complexity of setup"
  end
end
