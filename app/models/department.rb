# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Department < IdentitiesRecord
  self.implicit_order_column = :created_at

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

  validates :department_status_id,
            length: { maximum: 255 },
            uniqueness: { scope: :parent_id,
                          message: :already_tagged, }
end
