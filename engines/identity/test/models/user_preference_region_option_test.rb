# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preference_region_options
# Database name: principal
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = UserPreferenceRegionOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "name returns US for US id" do
    option = UserPreferenceRegionOption.find_or_create_by!(id: UserPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns JP for JP id" do
    option = UserPreferenceRegionOption.find_or_create_by!(id: UserPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "name returns nil for NOTHING id" do
    option = UserPreferenceRegionOption.find_or_create_by!(id: UserPreferenceRegionOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = UserPreferenceRegionOption.create!(id: 999)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    # Create new options with high IDs to avoid conflicts
    UserPreferenceRegionOption.create!(id: 1000)
    UserPreferenceRegionOption.create!(id: 1001)
    UserPreferenceRegionOption.create!(id: 1002)

    test_defaults = [1000, 1001, 1002]
    UserPreferenceRegionOption.stub(:default_ids, test_defaults) do
      # Delete any existing default options to test creation
      UserPreferenceRegionOption.where(id: test_defaults).delete_all

      # Ensure defaults are created
      UserPreferenceRegionOption.ensure_defaults!

      # Check that all default options exist
      assert UserPreferenceRegionOption.exists?(1000)
      assert UserPreferenceRegionOption.exists?(1001)
      assert UserPreferenceRegionOption.exists?(1002)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    # Create test options
    UserPreferenceRegionOption.create!(id: 2000)
    UserPreferenceRegionOption.create!(id: 2001)
    UserPreferenceRegionOption.create!(id: 2002)

    test_defaults = [2000, 2001, 2002]
    UserPreferenceRegionOption.stub(:default_ids, test_defaults) do
      # Ensure defaults exist first
      UserPreferenceRegionOption.ensure_defaults!

      # Count existing options
      count_before = UserPreferenceRegionOption.where(id: test_defaults).count

      # Run ensure_defaults! again
      UserPreferenceRegionOption.ensure_defaults!

      # Count should be the same
      count_after = UserPreferenceRegionOption.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    UserPreferenceRegionOption.stub(:default_ids, []) do
      # Should not raise an error
      assert_nothing_raised do
        UserPreferenceRegionOption.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    UserPreferenceRegionOption.stub(:default_ids, nil) do
      # Should not raise an error
      assert_nothing_raised do
        UserPreferenceRegionOption.ensure_defaults!
      end
    end
  end

  test "DEFAULTS contains expected values" do
    expected = [UserPreferenceRegionOption::NOTHING,
                UserPreferenceRegionOption::US,
                UserPreferenceRegionOption::JP,]

    assert_equal expected, UserPreferenceRegionOption::DEFAULTS
  end

  test "DEFAULTS is frozen" do
    assert_predicate UserPreferenceRegionOption::DEFAULTS, :frozen?
  end

  test "has_many association with user_preference_regions" do
    option = UserPreferenceRegionOption.create!(id: 999)

    # Verify the association exists
    assert_respond_to option, :user_preference_regions
    assert_equal [], option.user_preference_regions.to_a
  end

  test "dependent restrict_with_error on user_preference_regions" do
    option = user_preference_regions(:one).option

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end
end
