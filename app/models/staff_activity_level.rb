# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

class StaffActivityLevel < ActivityRecord
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :staff_activities,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_activity_level
end
