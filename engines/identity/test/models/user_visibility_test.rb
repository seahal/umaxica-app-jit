# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_visibilities
# Database name: principal
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserVisibilityTest < ActiveSupport::TestCase
  fixtures :user_visibilities, :users

  test "has correct constants" do
    assert_equal 0, UserVisibility::NOTHING
    assert_equal 1, UserVisibility::USER
    assert_equal 2, UserVisibility::STAFF
    assert_equal 3, UserVisibility::BOTH
  end

  test "can load nothing status from db" do
    status = UserVisibility.find(UserVisibility::NOTHING)

    assert_equal 0, status.id
  end

  test "has expected fixed ids" do
    assert UserVisibility.exists?(id: UserVisibility::NOTHING)
    assert UserVisibility.exists?(id: UserVisibility::USER)
    assert UserVisibility.exists?(id: UserVisibility::STAFF)
    assert UserVisibility.exists?(id: UserVisibility::BOTH)
  end

  test "has many users association" do
    assoc = UserVisibility.reflect_on_association(:users)

    assert_not_nil assoc
    assert_equal :has_many, assoc.macro
  end

  test "ensure_defaults! does nothing when defaults exist" do
    assert_no_difference "UserVisibility.count" do
      UserVisibility.ensure_defaults!
    end
  end
end
