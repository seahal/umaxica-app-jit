# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class HandleAssignmentStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :handle_assignments, dependent: :restrict_with_error
end
