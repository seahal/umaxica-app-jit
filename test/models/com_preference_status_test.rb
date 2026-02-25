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

  test "ordered scope sorts by position then id" do
    ordered = ComPreferenceStatus.ordered.pluck(:id)

    assert_equal [ComPreferenceStatus::DELETED, ComPreferenceStatus::NEYO], ordered
  end

  test "accepts integer ids" do
    status = ComPreferenceStatus.new(id: 3)

    assert_predicate status, :valid?
  end
end
