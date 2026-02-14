# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_visibilities
# Database name: operator
#
#  id :bigint           not null, primary key
#
class StaffVisibility < OperatorRecord
  NOBODY = 0
  USER = 1
  STAFF = 2
  BOTH = 3

  has_many :staffs,
           foreign_key: :visibility_id,
           dependent: :restrict_with_error,
           inverse_of: :visibility
end
