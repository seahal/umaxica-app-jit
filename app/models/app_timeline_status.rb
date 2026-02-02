# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_statuses
# Database name: news
#
#  id :bigint           not null, primary key
#

class AppTimelineStatus < NewsRecord
  has_many :app_timelines,
           foreign_key: :status_id,
           inverse_of: :app_timeline_status,
           dependent: :restrict_with_error
end
