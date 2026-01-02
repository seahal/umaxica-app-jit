# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  description     :text             default(""), not null
#  key             :string           default(""), not null
#  name            :string           default(""), not null
#  organization_id :uuid             not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_roles_on_organization_id  (organization_id)
#

class Role < IdentitiesRecord
  self.implicit_order_column = :created_at
  belongs_to :organization, class_name: "Workspace", inverse_of: :roles
  has_many :role_assignments, dependent: :destroy, inverse_of: :role
  has_many :users, through: :role_assignments, source: :user
  has_many :staffs, through: :role_assignments, source: :staff
end
