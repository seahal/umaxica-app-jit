# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
require "test_helper"

class StaffSecretStatusTest < ActiveSupport::TestCase
  test "ACTIVE status exists" do
    assert StaffSecretStatus.exists?(id: StaffSecretStatus::ACTIVE)
  end
end
