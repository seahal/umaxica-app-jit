# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#

class StaffStatus < OperatorRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  NEYO = 2

  # Use Rails convention `status_id` as the foreign key on `staffs`.
  has_many :staffs,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_status
end
