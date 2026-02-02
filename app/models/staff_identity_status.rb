# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_staff_identity_statuses_on_code  (code) UNIQUE
#
class StaffIdentityStatus < OperatorRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
end
