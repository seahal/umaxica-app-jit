# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_handle_assignment_statuses_on_code  (code) UNIQUE
#
class HandleAssignmentStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :handle_assignments, dependent: :restrict_with_error
end
