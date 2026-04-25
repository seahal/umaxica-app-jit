# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_dbsc_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
require "test_helper"

class OrgPreferenceDbscStatusTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "OrgPreferenceDbscStatus", OrgPreferenceDbscStatus.name
  end
end
