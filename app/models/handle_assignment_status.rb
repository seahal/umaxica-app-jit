# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_handle_assignment_statuses_on_id  (id) UNIQUE
#
class HandleAssignmentStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :handle_assignments, dependent: :restrict_with_error
end
