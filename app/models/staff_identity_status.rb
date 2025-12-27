# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class StaffIdentityStatus < IdentitiesRecord
  include UppercaseId

  # Use Rails convention `staff_identity_status_id` as the foreign key on `staffs`.
  has_many :staffs, dependent: :restrict_with_error, inverse_of: :staff_identity_status

  # Status constants
  NEYO = "NEYO"
end
