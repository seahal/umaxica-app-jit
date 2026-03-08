# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#
require "test_helper"

class OrgPreferenceStatusTest < ActiveSupport::TestCase
  fixtures :org_preference_statuses

  test "returns all statuses" do
    ids = OrgPreferenceStatus.pluck(:id)

    assert_equal [1, 2], ids.sort
  end

  test "accepts integer ids" do
    status = OrgPreferenceStatus.new(id: 3)

    assert_predicate status, :valid?
  end
end
