# == Schema Information
#
# Table name: org_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class OrgTimelineStatus < BusinessesRecord
  include UppercaseId
end
