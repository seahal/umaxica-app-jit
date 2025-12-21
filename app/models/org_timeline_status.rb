# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
#
#  id :string           not null, primary key
#
class OrgTimelineStatus < BusinessesRecord
  include UppercaseId

  has_many :org_timelines, dependent: :restrict_with_error, inverse_of: :org_timeline_status
end
