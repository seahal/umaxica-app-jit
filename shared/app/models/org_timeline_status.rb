# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: publication
#
#  id :bigint           not null, primary key
#

class OrgTimelineStatus < PublicationRecord
  # Fixed IDs - do not modify these values
  NOTHING = 1
  ACTIVE = 2
  INACTIVE = 3
  PENDING = 4
  DELETED = 5
  DRAFT = 6
  ARCHIVED = 7

  has_many :org_timelines,
           foreign_key: :status_id,
           inverse_of: :org_timeline_status,
           dependent: :restrict_with_error
end
