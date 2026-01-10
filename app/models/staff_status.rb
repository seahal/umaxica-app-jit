# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class StaffStatus < OperatorRecord
  include StringPrimaryKey

  validates :id, uniqueness: { case_sensitive: false }

  # Use Rails convention `status_id` as the foreign key on `staffs`.
  has_many :staffs,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_status

  # Status constants
  NEYO = "NEYO"
end
