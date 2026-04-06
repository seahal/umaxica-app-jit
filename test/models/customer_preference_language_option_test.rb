# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_language_options
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class CustomerPreferenceLanguageOptionTest < ActiveSupport::TestCase
  def setup
    [1, 2, 3].each { |id| CustomerStatus.find_or_create_by!(id: id) }
    [0, 1, 2, 3].each { |id| CustomerVisibility.find_or_create_by!(id: id) }
  end

  test "can be created" do
    option = CustomerPreferenceLanguageOption.create!(id: 99)

    assert_not_nil option.id
  end

  test "has many customer_preference_languages" do
    customer = Customer.create!
    option = CustomerPreferenceLanguageOption.create!(id: 99)
    preference = CustomerPreference.create!(customer: customer)
    language = CustomerPreferenceLanguage.create!(preference: preference, option: option)

    assert_includes option.customer_preference_languages, language
  end

  test "restricts deletion when associated records exist" do
    customer = Customer.create!
    option = CustomerPreferenceLanguageOption.create!(id: 99)
    preference = CustomerPreference.create!(customer: customer)
    CustomerPreferenceLanguage.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "name returns ja for JA id" do
    option = CustomerPreferenceLanguageOption.find_or_create_by!(id: CustomerPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = CustomerPreferenceLanguageOption.find_or_create_by!(id: CustomerPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for NOTHING id" do
    option = CustomerPreferenceLanguageOption.find_or_create_by!(id: CustomerPreferenceLanguageOption::NOTHING)

    assert_nil option.name
  end

  test "ensure_defaults! creates missing default options" do
    CustomerPreferenceLanguageOption.stub(:default_ids, CustomerPreferenceLanguageOption::DEFAULTS) do
      CustomerPreferenceLanguageOption.where(id: CustomerPreferenceLanguageOption::DEFAULTS).delete_all
      CustomerPreferenceLanguageOption.ensure_defaults!

      assert CustomerPreferenceLanguageOption.exists?(CustomerPreferenceLanguageOption::NOTHING)
      assert CustomerPreferenceLanguageOption.exists?(CustomerPreferenceLanguageOption::JA)
      assert CustomerPreferenceLanguageOption.exists?(CustomerPreferenceLanguageOption::EN)
    end
  end

  test "ensure_defaults! does not recreate existing options" do
    CustomerPreferenceLanguageOption.ensure_defaults!

    CustomerPreferenceLanguageOption.stub(:default_ids, CustomerPreferenceLanguageOption::DEFAULTS) do
      count_before = CustomerPreferenceLanguageOption.where(id: CustomerPreferenceLanguageOption::DEFAULTS).count
      CustomerPreferenceLanguageOption.ensure_defaults!
      count_after = CustomerPreferenceLanguageOption.where(id: CustomerPreferenceLanguageOption::DEFAULTS).count

      assert_equal count_before, count_after
    end
  end

  test "ensure_defaults! handles empty defaults" do
    CustomerPreferenceLanguageOption.stub(:default_ids, []) do
      assert_nothing_raised do
        CustomerPreferenceLanguageOption.ensure_defaults!
      end
    end
  end
end
