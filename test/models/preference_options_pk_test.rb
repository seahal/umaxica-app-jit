# frozen_string_literal: true

require "test_helper"

class PreferenceOptionsPkTest < ActiveSupport::TestCase
  test "AppPreferenceLanguageOption uses integer PK" do
    option = AppPreferenceLanguageOption.create!(id: 99)
    assert_equal 99, option.id
    assert_equal 99, option.reload.id
  end

  test "AppPreferenceRegionOption uses integer PK" do
    option = AppPreferenceRegionOption.create!(id: 99)
    assert_equal 99, option.id
  end

  test "ComPreferenceTimezoneOption uses integer PK" do
    option = ComPreferenceTimezoneOption.create!(id: 99)
    assert_equal 99, option.id
  end

  test "OrgPreferenceColorthemeOption uses integer PK" do
    option = OrgPreferenceColorthemeOption.create!(id: 99)
    assert_equal 99, option.id
  end

  test "Global fixture availability" do
    assert AppPreferenceLanguageOption.find(AppPreferenceLanguageOption::JA)
    assert AppPreferenceRegionOption.find(AppPreferenceRegionOption::US)
    assert AppPreferenceTimezoneOption.find(AppPreferenceTimezoneOption::ETC_UTC)
    assert AppPreferenceColorthemeOption.find(AppPreferenceColorthemeOption::LIGHT)
  end
end
