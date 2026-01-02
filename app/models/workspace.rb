# frozen_string_literal: true

# == Schema Information
#
# Table name: workspaces
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  domain              :string           default(""), not null
#  name                :string           default(""), not null
#  parent_organization :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_workspaces_on_domain               (domain) UNIQUE
#  index_workspaces_on_parent_organization  (parent_organization)
#

class Workspace < IdentitiesRecord
  self.table_name = "workspaces"

  has_many :user_workspaces,
           dependent: :destroy,
           inverse_of: :workspace
  has_many :users,
           through: :user_workspaces
  has_many :roles,
           foreign_key: :organization_id,
           dependent: :destroy,
           inverse_of: :organization
  has_many :role_assignments,
           through: :roles

  has_many :user_memberships,
           dependent: :destroy,
           inverse_of: :workspace

  validates :name, presence: true
  validates :domain, uniqueness: true
end
