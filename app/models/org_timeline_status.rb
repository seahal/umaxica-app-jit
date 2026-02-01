# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: news
#
#  id :integer          default(0), not null, primary key
#

class OrgTimelineStatus < NewsRecord
  include CodeIdentifiable

  has_many :org_timelines,
           foreign_key: :status_id,
           inverse_of: :org_timeline_status,
           dependent: :restrict_with_error
end
