# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_statuses
# Database name: news
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_app_timeline_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

class AppTimelineStatus < NewsRecord
  include StringPrimaryKey

  has_many :app_timelines,
           foreign_key: :status_id,
           inverse_of: :app_timeline_status,
           dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
