# == Schema Information
#
# Table name: com_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class ComTimelineStatus < BusinessesRecord
  include UppercaseId
end
