# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_handle_assignment_statuses_on_key  (key) UNIQUE
#

class HandleAssignmentStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :handle_assignments, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
