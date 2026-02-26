# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AvatarMonikerStatusTest < ActiveSupport::TestCase
  test "accepts integer ids" do
    status = AvatarMonikerStatus.new(id: 9)

    assert_predicate status, :valid?
  end

  test "constants are defined" do
    assert_equal 1, AvatarMonikerStatus::NOTHING
    assert_equal 2, AvatarMonikerStatus::ACTIVE
    assert_equal 3, AvatarMonikerStatus::INACTIVE
    assert_equal 4, AvatarMonikerStatus::DELETED
  end
end
