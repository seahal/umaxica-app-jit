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
end
