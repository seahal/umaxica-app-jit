# == Schema Information
#
# Table name: com_timeline_statuses
#
#  id :string           not null, primary key
#
class ComTimelineStatus < BusinessesRecord
  include UppercaseId

  has_many :com_timelines, dependent: :restrict_with_error, inverse_of: :com_timeline_status
end
