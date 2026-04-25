# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_statuses
# Database name: commerce
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComPreferenceStatusTest < ActiveSupport::TestCase
  fixtures :com_preference_statuses

  test "has correct constants" do
    assert_equal 1, ComPreferenceStatus::DELETED
    assert_equal 2, ComPreferenceStatus::NOTHING
  end

  test "defaults includes DELETED and NOTHING" do
    assert_includes ComPreferenceStatus::DEFAULTS, ComPreferenceStatus::DELETED
    assert_includes ComPreferenceStatus::DEFAULTS, ComPreferenceStatus::NOTHING
  end

  test "DEFAULTS is frozen" do
    assert_predicate ComPreferenceStatus::DEFAULTS, :frozen?
  end

  test "returns all statuses" do
    ids = ComPreferenceStatus.pluck(:id)

    assert_equal [ComPreferenceStatus::DELETED, ComPreferenceStatus::NOTHING], ids.sort
  end

  test "accepts integer ids" do
    status = ComPreferenceStatus.new(id: 3)

    assert_predicate status, :valid?
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "ComPreferenceStatus.count" do
      ComPreferenceStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! creates missing default options" do
    # Create new options with high IDs to avoid conflicts
    ComPreferenceStatus.create!(id: 1000)
    ComPreferenceStatus.create!(id: 1001)

    test_defaults = [1000, 1001]
    ComPreferenceStatus.stub(:default_ids, test_defaults) do
      # Delete any existing default options to test creation
      ComPreferenceStatus.where(id: test_defaults).delete_all

      # Ensure defaults are created
      ComPreferenceStatus.ensure_defaults!

      # Check that all default options exist
      assert ComPreferenceStatus.exists?(1000)
      assert ComPreferenceStatus.exists?(1001)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    # Create test options
    ComPreferenceStatus.create!(id: 2000)
    ComPreferenceStatus.create!(id: 2001)

    test_defaults = [2000, 2001]
    ComPreferenceStatus.stub(:default_ids, test_defaults) do
      # Ensure defaults exist first
      ComPreferenceStatus.ensure_defaults!

      # Count existing options
      count_before = ComPreferenceStatus.where(id: test_defaults).count

      # Run ensure_defaults! again
      ComPreferenceStatus.ensure_defaults!

      # Count should be the same
      count_after = ComPreferenceStatus.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    ComPreferenceStatus.stub(:default_ids, []) do
      # Should not raise an error
      assert_nothing_raised do
        ComPreferenceStatus.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    ComPreferenceStatus.stub(:default_ids, nil) do
      # Should not raise an error
      assert_nothing_raised do
        ComPreferenceStatus.ensure_defaults!
      end
    end
  end

  test "has_many association with com_preferences" do
    status = com_preference_statuses(:deleted)

    # Verify the association exists
    assert_respond_to status, :com_preferences
  end

  test "dependent restrict_with_error on com_preferences" do
    status = com_preference_statuses(:deleted)
    preference = ComPreference.create!(status_id: status.id)

    assert_includes status.com_preferences, preference

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      status.destroy!
    end
  end
end
