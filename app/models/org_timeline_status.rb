# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

class OrgTimelineStatus < NewsRecord
  has_many :org_timelines,
           foreign_key: :status_id,
           inverse_of: :org_timeline_status,
           dependent: :restrict_with_error
end
