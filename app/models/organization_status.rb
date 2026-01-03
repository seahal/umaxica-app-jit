# frozen_string_literal: true

class OrganizationStatus < IdentitiesRecord
  self.table_name = "department_statuses"

  include ::UppercaseId
  include ::CatTagMaster

  self.primary_key = "id"

  has_many :organizations,
           class_name: "Organization",
           foreign_key: :workspace_status_id,
           dependent: :restrict_with_error,
           inverse_of: :organization_status

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
end
