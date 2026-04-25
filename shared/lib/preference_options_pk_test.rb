# typed: false
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

  test "fixed colortheme option ids are available across preference surfaces" do
    assert AppPreferenceColorthemeOption.find(AppPreferenceColorthemeOption::LIGHT)
    assert AppPreferenceColorthemeOption.find(AppPreferenceColorthemeOption::DARK)
    assert AppPreferenceColorthemeOption.find(AppPreferenceColorthemeOption::SYSTEM)

    assert ComPreferenceColorthemeOption.find(ComPreferenceColorthemeOption::LIGHT)
    assert ComPreferenceColorthemeOption.find(ComPreferenceColorthemeOption::DARK)
    assert ComPreferenceColorthemeOption.find(ComPreferenceColorthemeOption::SYSTEM)

    assert OrgPreferenceColorthemeOption.find(OrgPreferenceColorthemeOption::LIGHT)
    assert OrgPreferenceColorthemeOption.find(OrgPreferenceColorthemeOption::DARK)
    assert OrgPreferenceColorthemeOption.find(OrgPreferenceColorthemeOption::SYSTEM)
  end
end
