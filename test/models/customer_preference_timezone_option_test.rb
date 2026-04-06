# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_timezone_options
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = CustomerPreferenceTimezoneOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "name returns Etc/UTC for ETC_UTC id" do
    option = CustomerPreferenceTimezoneOption.find_or_create_by!(id: CustomerPreferenceTimezoneOption::ETC_UTC)

    assert_equal "Etc/UTC", option.name
  end

  test "name returns Asia/Tokyo for ASIA_TOKYO id" do
    option = CustomerPreferenceTimezoneOption.find_or_create_by!(id: CustomerPreferenceTimezoneOption::ASIA_TOKYO)

    assert_equal "Asia/Tokyo", option.name
  end

  test "name returns nil for unknown id" do
    option = CustomerPreferenceTimezoneOption.find_or_create_by!(id: 999)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    CustomerPreferenceTimezoneOption.create!(id: 1000)
    CustomerPreferenceTimezoneOption.create!(id: 1001)

    test_defaults = [1000, 1001]
    CustomerPreferenceTimezoneOption.stub(:default_ids, test_defaults) do
      CustomerPreferenceTimezoneOption.where(id: test_defaults).delete_all
      CustomerPreferenceTimezoneOption.ensure_defaults!

      assert CustomerPreferenceTimezoneOption.exists?(1000)
      assert CustomerPreferenceTimezoneOption.exists?(1001)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    CustomerPreferenceTimezoneOption.create!(id: 2000)
    CustomerPreferenceTimezoneOption.create!(id: 2001)

    test_defaults = [2000, 2001]
    CustomerPreferenceTimezoneOption.stub(:default_ids, test_defaults) do
      CustomerPreferenceTimezoneOption.ensure_defaults!
      count_before = CustomerPreferenceTimezoneOption.where(id: test_defaults).count
      CustomerPreferenceTimezoneOption.ensure_defaults!
      count_after = CustomerPreferenceTimezoneOption.where(id: test_defaults).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    CustomerPreferenceTimezoneOption.stub(:default_ids, []) do
      assert_nothing_raised do
        CustomerPreferenceTimezoneOption.ensure_defaults!
      end
    end
  end

  test "DEFAULTS contains expected values" do
    expected = [CustomerPreferenceTimezoneOption::ETC_UTC,
                CustomerPreferenceTimezoneOption::ASIA_TOKYO,]

    assert_equal expected, CustomerPreferenceTimezoneOption::DEFAULTS
  end

  test "DEFAULTS is frozen" do
    assert_predicate CustomerPreferenceTimezoneOption::DEFAULTS, :frozen?
  end
end
