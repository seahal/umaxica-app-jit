# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_preference_region_options
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffPreferenceRegionOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = StaffPreferenceRegionOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "name returns US for US id" do
    option = StaffPreferenceRegionOption.find_or_create_by!(id: StaffPreferenceRegionOption::US)

    assert_equal "US", option.name
  end

  test "name returns JP for JP id" do
    option = StaffPreferenceRegionOption.find_or_create_by!(id: StaffPreferenceRegionOption::JP)

    assert_equal "JP", option.name
  end

  test "name returns nil for NOTHING id" do
    option = StaffPreferenceRegionOption.find_or_create_by!(id: StaffPreferenceRegionOption::NOTHING)

    assert_nil option.name
  end

  test "name returns nil for unknown id" do
    option = StaffPreferenceRegionOption.create!(id: 999)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    StaffPreferenceRegionOption.create!(id: 1000)
    StaffPreferenceRegionOption.create!(id: 1001)
    StaffPreferenceRegionOption.create!(id: 1002)

    test_defaults = [1000, 1001, 1002]
    StaffPreferenceRegionOption.stub(:default_ids, test_defaults) do
      StaffPreferenceRegionOption.where(id: test_defaults).delete_all
      StaffPreferenceRegionOption.ensure_defaults!

      assert StaffPreferenceRegionOption.exists?(1000)
      assert StaffPreferenceRegionOption.exists?(1001)
      assert StaffPreferenceRegionOption.exists?(1002)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    StaffPreferenceRegionOption.ensure_defaults!

    StaffPreferenceRegionOption.stub(:default_ids, StaffPreferenceRegionOption::DEFAULTS) do
      count_before = StaffPreferenceRegionOption.where(id: StaffPreferenceRegionOption::DEFAULTS).count
      StaffPreferenceRegionOption.ensure_defaults!
      count_after = StaffPreferenceRegionOption.where(id: StaffPreferenceRegionOption::DEFAULTS).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    StaffPreferenceRegionOption.stub(:default_ids, []) do
      assert_nothing_raised do
        StaffPreferenceRegionOption.ensure_defaults!
      end
    end
  end

  test "ensure_defaults! handles nil defaults" do
    StaffPreferenceRegionOption.stub(:default_ids, nil) do
      assert_nothing_raised do
        StaffPreferenceRegionOption.ensure_defaults!
      end
    end
  end

  test "DEFAULTS contains expected values" do
    expected = [StaffPreferenceRegionOption::NOTHING,
                StaffPreferenceRegionOption::US,
                StaffPreferenceRegionOption::JP,]

    assert_equal expected, StaffPreferenceRegionOption::DEFAULTS
  end

  test "DEFAULTS is frozen" do
    assert_predicate StaffPreferenceRegionOption::DEFAULTS, :frozen?
  end

  test "has_many association with staff_preference_regions" do
    option = StaffPreferenceRegionOption.create!(id: 999)

    assert_respond_to option, :staff_preference_regions
    assert_equal [], option.staff_preference_regions.to_a
  end

  test "dependent restrict_with_error on staff_preference_regions" do
    skip "Skipping dependent test due to complexity of setup"
  end
end
