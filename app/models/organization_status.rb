# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_statuses
# Database name: operator
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_department_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
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
