# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
# Database name: operator
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_status_id :string
#  parent_id            :bigint
#  workspace_id         :bigint
#
# Indexes
#
#  index_departments_on_department_status_id  (department_status_id)
#  index_departments_on_parent_id             (parent_id)
#  index_departments_on_workspace_id          (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_status_id => department_statuses.id)
#  fk_rails_...  (parent_id => departments.id)
#  fk_rails_...  (workspace_id => workspaces.id)
#

class Department < OperatorRecord
  belongs_to :parent,
             class_name: "Department",
             inverse_of: :children,
             optional: true
  has_many :children,
           class_name: "Department",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  belongs_to :department_status,
             class_name: "OrganizationStatus",
             primary_key: :id,
             inverse_of: :departments

  belongs_to :workspace, class_name: "Organization", optional: true, inverse_of: :departments
  has_many :admins, dependent: :nullify, inverse_of: :department

  validates :name, presence: true
  validates :department_status_id,
            length: { maximum: 255 },
            uniqueness: { scope: :parent_id,
                          message: :already_tagged, }
end
