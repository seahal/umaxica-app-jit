# frozen_string_literal: true

class OrganizationStatus < OperatorRecord
  include StringPrimaryKey

  has_many :organizations,
           class_name: "Organization",
           foreign_key: :workspace_status_id,
           dependent: :restrict_with_error,
           inverse_of: :organization_status
  has_many :departments,
           class_name: "Department",
           dependent: :restrict_with_error,
           inverse_of: :department_status
  validates :id, uniqueness: { case_sensitive: false }

  self.primary_key = "id"
end
