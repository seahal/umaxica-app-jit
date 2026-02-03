# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class ClientStatusTest < ActiveSupport::TestCase
  test "status constants are defined" do
    assert_equal 1, ClientStatus::ACTIVE
    assert_equal 2, ClientStatus::INACTIVE
    assert_equal 3, ClientStatus::PENDING
    assert_equal 4, ClientStatus::DELETED
    assert_equal 5, ClientStatus::NEYO
  end
end
