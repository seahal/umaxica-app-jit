# == Schema Information
#
# Table name: app_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class AppTimelineStatus < BusinessesRecord
  include UppercaseId
end
