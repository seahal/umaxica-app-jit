# == Schema Information
#
# Table name: workspaces
#
#  id                  :uuid             not null, primary key
#  name                :string           default(""), not null
#  domain              :string           default(""), not null
#  parent_organization :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  department_id       :uuid
#  parent_id           :uuid
#  workspace_status_id :string(255)
#  admin_id            :uuid
#
# Indexes
#
#  index_workspaces_on_admin_id             (admin_id)
#  index_workspaces_on_department_id        (department_id)
#  index_workspaces_on_domain               (domain) UNIQUE
#  index_workspaces_on_parent_id            (parent_id)
#  index_workspaces_on_workspace_status_id  (workspace_status_id)
#

# frozen_string_literal: true

class Workspace < IdentitiesRecord
  self.implicit_order_column = :created_at

  belongs_to :workspace_status,
             primary_key: :id,
             optional: true,
             inverse_of: :workspaces
  has_many :departments, dependent: :nullify, inverse_of: :workspace
  has_many :user_memberships, dependent: :destroy, inverse_of: :workspace
end
