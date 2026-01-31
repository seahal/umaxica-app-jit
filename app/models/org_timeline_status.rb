# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: news
#
#  id :integer          default(0), not null, primary key
# 

class OrgTimelineStatus < NewsRecord
  has_many :org_timelines,
           foreign_key: :status_id,
           inverse_of: :org_timeline_status,
           dependent: :restrict_with_error
  validates :id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
