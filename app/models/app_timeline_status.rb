# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class AppTimelineStatus < NewsRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }

  has_many :app_timelines,
           foreign_key: :status_id,
           inverse_of: :app_timeline_status,
           dependent: :restrict_with_error

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
