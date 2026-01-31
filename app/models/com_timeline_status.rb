# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_statuses
# Database name: news
#
#  id :integer          default(0), not null, primary key
# 

class ComTimelineStatus < NewsRecord
  has_many :com_timelines,
           foreign_key: :status_id,
           inverse_of: :com_timeline_status,
           dependent: :restrict_with_error
  validates :id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
