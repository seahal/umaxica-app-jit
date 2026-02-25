# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserActivityLevelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "accepts integer ids" do
    record = UserActivityLevel.new(id: 9)

    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, UserActivityLevel::DEBUG
    assert_equal 2, UserActivityLevel::ERROR
    assert_equal 3, UserActivityLevel::INFO
    assert_equal 4, UserActivityLevel::NEYO
    assert_equal 5, UserActivityLevel::WARN
  end

  test "ensure_defaults! creates records" do
    UserActivityLevel.delete_all
    assert_difference("UserActivityLevel.count", 5) do
      UserActivityLevel.ensure_defaults!
    end
    assert UserActivityLevel.exists?(id: UserActivityLevel::DEBUG)
  end

  test "ordered scope returns ordered records" do
    UserActivityLevel.ensure_defaults!
    levels = UserActivityLevel.ordered

    assert_kind_of ActiveRecord::Relation, levels
    ordered_ids = levels.pluck(:id)

    assert_equal ordered_ids.sort, ordered_ids
  end
end
