# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id                   :uuid             not null, primary key
#  parent_id            :uuid
#  department_status_id :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_departments_on_department_status_id  (department_status_id)
#  index_departments_on_parent_id             (parent_id)
#  index_organizations_unique                 (parent_id,department_status_id) UNIQUE
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

  validates :department_status_id,
            length: { maximum: 255 },
            uniqueness: { scope: :parent_id,
                          message: :already_tagged, }
end
