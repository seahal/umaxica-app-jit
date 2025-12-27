# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class OrgTimelineStatus < NewsRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }

  has_many :org_timelines,
           foreign_key: :status_id,
           inverse_of: :org_timeline_status,
           dependent: :restrict_with_error
end
