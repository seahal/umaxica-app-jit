# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceStatusTest < ActiveSupport::TestCase
  fixtures :com_preference_statuses

  test "returns all statuses" do
    ids = ComPreferenceStatus.pluck(:id)

    assert_equal [ComPreferenceStatus::DELETED, ComPreferenceStatus::NOTHING], ids.sort
  end

  test "accepts integer ids" do
    status = ComPreferenceStatus.new(id: 3)

    assert_predicate status, :valid?
  end
end
