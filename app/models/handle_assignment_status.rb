# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id :integer          not null, primary key, limit: 2
#
class HandleAssignmentStatus < AvatarRecord
  self.record_timestamps = false

  has_many :handle_assignments, dependent: :restrict_with_error
end
