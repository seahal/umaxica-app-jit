# frozen_string_literal: true

# == Schema Information
#
# Table name: workspaces
#
#  id                  :uuid             not null, primary key
#  name                :string
#  domain              :string
#  parent_organization :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Workspace < IdentityRecord
  self.table_name = "workspaces"

  has_many :user_organizations,
           foreign_key: :organization_id,
           dependent: :destroy,
           inverse_of: :organization
  has_many :users, through: :user_organizations
  has_many :roles,
           foreign_key: :organization_id,
           dependent: :destroy,
           inverse_of: :organization
  has_many :role_assignments, through: :roles

  has_many :user_memberships,
           dependent: :destroy,
           inverse_of: :workspace

  validates :name, presence: true
end
