# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_statuses
# Database name: operator
#
#  id :string           not null, primary key
#

class StaffStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  # Use Rails convention `status_id` as the foreign key on `staffs`.
  has_many :staffs,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_status
end
