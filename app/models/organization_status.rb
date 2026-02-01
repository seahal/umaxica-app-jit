# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_statuses
# Database name: operator
#
#  id :string           not null, primary key
#
class OrganizationStatus < OperatorRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :organizations,
           class_name: "Organization",
           foreign_key: :workspace_status_id,
           dependent: :restrict_with_error,
           inverse_of: :organization_status
  has_many :departments,
           class_name: "Department",
           dependent: :restrict_with_error,
           inverse_of: :department_status

  self.primary_key = "id"
end
