# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class HandleAssignmentStatus < AvatarRecord
  include StringPrimaryKey

  has_many :handle_assignments, dependent: :restrict_with_error
end
