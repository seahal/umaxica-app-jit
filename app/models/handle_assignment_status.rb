# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HandleAssignmentStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :handle_assignments, dependent: :restrict_with_error

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
