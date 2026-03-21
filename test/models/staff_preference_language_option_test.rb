# typed: false
# frozen_string_literal: true

require "test_helper"

class StaffPreferenceLanguageOptionTest < ActiveSupport::TestCase
  test "name returns ja for JA id" do
    option = StaffPreferenceLanguageOption.find_or_create_by!(id: StaffPreferenceLanguageOption::JA)

    assert_equal "ja", option.name
  end

  test "name returns en for EN id" do
    option = StaffPreferenceLanguageOption.find_or_create_by!(id: StaffPreferenceLanguageOption::EN)

    assert_equal "en", option.name
  end

  test "name returns nil for unknown id" do
    option = StaffPreferenceLanguageOption.find_or_create_by!(id: 999)

    assert_nil option.name
  end
end
