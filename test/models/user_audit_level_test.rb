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
end
