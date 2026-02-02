# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_user_audit_levels_on_code  (code) UNIQUE
#

require "test_helper"

class UserAuditLevelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = UserAuditLevel.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
