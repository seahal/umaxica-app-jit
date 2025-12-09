# == Schema Information
#
# Table name: app_timeline_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AppTimelineStatus < BusinessesRecord
  has_many :app_timelines, dependent: :restrict_with_error, inverse_of: :app_timeline_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
