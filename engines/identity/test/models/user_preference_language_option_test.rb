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
    # Create new options with high IDs to avoid conflicts
    UserPreferenceLanguageOption.create!(id: 1000)
    UserPreferenceLanguageOption.create!(id: 1001)

    test_defaults = [1000, 1001]
    UserPreferenceLanguageOption.stub(:default_ids, test_defaults) do
      # Delete any existing default options to test creation
      UserPreferenceLanguageOption.where(id: test_defaults).delete_all

      # Ensure defaults are created
      UserPreferenceLanguageOption.ensure_defaults!

      # Check that all default options exist
      assert UserPreferenceLanguageOption.exists?(1000)
      assert UserPreferenceLanguageOption.exists?(1001)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    # Create test options
    UserPreferenceLanguageOption.create!(id: 2000)
    UserPreferenceLanguageOption.create!(id: 2001)

    test_defaults = [2000, 2001]
    UserPreferenceLanguageOption.stub(:default_ids, test_defaults) do
      # Ensure defaults exist first
      UserPreferenceLanguageOption.ensure_defaults!

      # Count existing options
      count_before = UserPreferenceLanguageOption.where(id: test_defaults).count

      # Run ensure_defaults! again
      UserPreferenceLanguageOption.ensure_defaults!

      # Count should be the same
      count_after = UserPreferenceLanguageOption.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    UserPreferenceLanguageOption.stub(:default_ids, []) do
      # Should not raise an error
      assert_nothing_raised do
        UserPreferenceLanguageOption.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    UserPreferenceLanguageOption.stub(:default_ids, nil) do
      # Should not raise an error
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

    # Verify the association exists
    assert_respond_to option, :user_preference_languages
    assert_equal [], option.user_preference_languages.to_a
  end

  test "dependent restrict_with_error on user_preference_languages" do
    option = user_preference_languages(:one).option

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
