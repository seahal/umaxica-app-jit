# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class UserAuditLevelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "accepts integer ids" do
    record = UserAuditLevel.new(id: 9)
    assert_predicate record, :valid?
  end

  test "constants are defined" do
    assert_equal 1, UserAuditLevel::DEBUG
    assert_equal 2, UserAuditLevel::ERROR
    assert_equal 3, UserAuditLevel::INFO
    assert_equal 4, UserAuditLevel::NEYO
    assert_equal 5, UserAuditLevel::WARN
  end

  test "ensure_defaults! creates records" do
    UserAuditLevel.delete_all
    assert_difference("UserAuditLevel.count", 5) do
      UserAuditLevel.ensure_defaults!
    end
    assert UserAuditLevel.exists?(id: UserAuditLevel::DEBUG)
  end

  test "ordered scope returns ordered records" do
    UserAuditLevel.ensure_defaults!
    levels = UserAuditLevel.ordered
    assert_kind_of ActiveRecord::Relation, levels
    ordered_ids = levels.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
