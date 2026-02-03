# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

class ComTimelineStatus < NewsRecord
  # Fixed IDs - do not modify these values
  NEYO = 1
  ACTIVE = 2
  INACTIVE = 3
  PENDING = 4
  DELETED = 5
  DRAFT = 6
  ARCHIVED = 7

  has_many :com_timelines,
           foreign_key: :status_id,
           inverse_of: :com_timeline_status,
           dependent: :restrict_with_error
end
