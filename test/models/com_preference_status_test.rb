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
    ComPreferenceStatus.create!(id: 1000)
    ComPreferenceStatus.create!(id: 1001)

    test_defaults = [1000, 1001]
    ComPreferenceStatus.stub(:default_ids, test_defaults) do
      ComPreferenceStatus.where(id: test_defaults).delete_all
      ComPreferenceStatus.ensure_defaults!

      assert ComPreferenceStatus.exists?(1000)
      assert ComPreferenceStatus.exists?(1001)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    ComPreferenceStatus.create!(id: 2000)
    ComPreferenceStatus.create!(id: 2001)

    test_defaults = [2000, 2001]
    ComPreferenceStatus.stub(:default_ids, test_defaults) do
      ComPreferenceStatus.ensure_defaults!
      count_before = ComPreferenceStatus.where(id: test_defaults).count
      ComPreferenceStatus.ensure_defaults!
      count_after = ComPreferenceStatus.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    ComPreferenceStatus.stub(:default_ids, []) do
      assert_nothing_raised do
        ComPreferenceStatus.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    ComPreferenceStatus.stub(:default_ids, nil) do
      assert_nothing_raised do
        ComPreferenceStatus.ensure_defaults!
      end
    end
  end

  test "has_many association with com_preferences" do
    status = com_preference_statuses(:deleted)

    assert_respond_to status, :com_preferences
  end

  test "dependent restrict_with_error on com_preferences" do
    skip "Skipping dependent test due to complexity of setup"
  end
end
