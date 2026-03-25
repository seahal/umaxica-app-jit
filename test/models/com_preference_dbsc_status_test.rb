# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_dbsc_statuses
# Database name: commerce
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceDbscStatusTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "ComPreferenceDbscStatus", ComPreferenceDbscStatus.name
  end
end
