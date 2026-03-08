# typed: false
# == Schema Information
#
# Table name: organizations
# Database name: operator
#
#  id                  :bigint           not null, primary key
#  domain              :string           default(""), not null
#  name                :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  department_id       :bigint
#  operator_id         :bigint
#  parent_id           :bigint
#  workspace_status_id :bigint           default(0), not null
#
# Indexes
#
#  index_organizations_on_department_id        (department_id)
#  index_organizations_on_domain               (domain) UNIQUE
#  index_organizations_on_operator_id          (operator_id)
#  index_organizations_on_parent_id            (parent_id)
#  index_organizations_on_workspace_status_id  (workspace_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_status_id => organization_statuses.id)
#

# frozen_string_literal: true

# Organization mirrors Workspace but keeps the legacy name.
class Organization < OperatorRecord
  belongs_to :organization_status,
             class_name: "OrganizationStatus",
             foreign_key: :workspace_status_id,
             primary_key: :id,
             optional: true,
             inverse_of: :organizations

  has_many :divisions,
           dependent: :nullify,
           inverse_of: :organization
  has_many :departments, dependent: :nullify, inverse_of: :workspace
  has_many :user_memberships, dependent: :destroy, inverse_of: :workspace

  validates :domain, uniqueness: true
  validates :workspace_status_id, numericality: { only_integer: true }, allow_nil: true
end
