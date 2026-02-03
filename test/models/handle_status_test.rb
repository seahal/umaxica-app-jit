# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class HandleStatusTest < ActiveSupport::TestCase
  fixtures :handle_statuses

  test "validations" do
    status = HandleStatus.new(id: HandleStatus::PENDING)
    assert_predicate status, :valid?
  end

  test "can load active status from db" do
    status = HandleStatus.find(HandleStatus::ACTIVE)
    assert_not_nil status
    assert_equal HandleStatus::ACTIVE, status.id
  end
end
