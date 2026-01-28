# frozen_string_literal: true

require "test_helper"

class PreferenceOptionsPkTest < ActiveSupport::TestCase
  test "AppPreferenceLanguageOption uses string PK" do
    option = AppPreferenceLanguageOption.create!(id: "TEST_LANG")
    assert_equal "TEST_LANG", option.id
    assert_equal "TEST_LANG", option.reload.id
  end

  test "AppPreferenceRegionOption uses string PK" do
    option = AppPreferenceRegionOption.create!(id: "TEST_REGION")
    assert_equal "TEST_REGION", option.id
  end

  test "ComPreferenceTimezoneOption uses string PK" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_TZ")
    assert_equal "TEST_TZ", option.id
  end

  test "OrgPreferenceColorthemeOption uses string PK" do
    option = OrgPreferenceColorthemeOption.create!(id: "TEST_THEME")
    assert_equal "TEST_THEME", option.id
  end

  test "Global fixture availability" do
    assert AppPreferenceLanguageOption.find("JA")
    assert AppPreferenceRegionOption.find("US")
    assert AppPreferenceTimezoneOption.find("Etc/UTC")
    assert AppPreferenceColorthemeOption.find("light")
  end
end
