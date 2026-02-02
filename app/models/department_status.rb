# frozen_string_literal: true

# == Schema Information
#
# Table name: department_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_department_statuses_on_code  (code) UNIQUE
#

class DepartmentStatus < OperatorRecord
  include CodeIdentifiable

  has_many :departments,
           inverse_of: :department_status,
           dependent: :restrict_with_error
end
