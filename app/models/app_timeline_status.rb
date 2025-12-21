# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_statuses
#
#  id :string           not null, primary key
#
class AppTimelineStatus < BusinessesRecord
  include UppercaseId

  has_many :app_timelines, dependent: :restrict_with_error, inverse_of: :app_timeline_status
end
