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

  test "has expected fixed ids" do
    assert UserVisibility.exists?(id: UserVisibility::NOBODY)
    assert UserVisibility.exists?(id: UserVisibility::USER)
    assert UserVisibility.exists?(id: UserVisibility::STAFF)
    assert UserVisibility.exists?(id: UserVisibility::BOTH)
  end

  test "has many users association" do
    assoc = UserVisibility.reflect_on_association(:users)

    assert_not_nil assoc
    assert_equal :has_many, assoc.macro
  end
end
