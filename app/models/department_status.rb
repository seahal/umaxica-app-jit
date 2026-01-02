# frozen_string_literal: true

# == Schema Information
#
# Table name: department_statuses
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DepartmentStatus < IdentitiesRecord
  include ::UppercaseId
  include ::CatTagMaster

  self.primary_key = "id"

  has_many :departments, dependent: :restrict_with_error

  validates :id, presence: true, uniqueness: true, length: { maximum: 255 }
end
