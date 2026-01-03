# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id                   :uuid             not null, primary key
#  name                 :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_status_id :string(255)
#  workspace_id         :uuid
#  parent_id            :uuid
#
# Indexes
#
#  index_departments_on_department_status_id  (department_status_id)
#  index_departments_on_parent_id             (parent_id)
#  index_departments_on_status_and_parent     (department_status_id,parent_id) UNIQUE
#  index_departments_on_workspace_id          (workspace_id)
#

class Department < IdentitiesRecord
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
             primary_key: :id,
             inverse_of: :departments

  belongs_to :workspace, optional: true, inverse_of: :departments
  has_many :admins, dependent: :nullify, inverse_of: :department

  validates :name, presence: true
  validates :department_status_id,
            length: { maximum: 255 },
            uniqueness: { scope: :parent_id,
                          message: :already_tagged, }
end
