# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_moniker_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class AvatarMonikerStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMonikerStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end

  test "validates length of id" do
    record = AvatarMonikerStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
