# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secret_statuses
# Database name: operator
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_staff_identity_secret_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class StaffSecretStatusTest < ActiveSupport::TestCase
  test "ACTIVE status exists" do
    assert StaffSecretStatus.exists?(id: StaffSecretStatus::ACTIVE)
  end
end
