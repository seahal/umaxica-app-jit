# == Schema Information
#
# Table name: com_timeline_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ComTimelineStatus < BusinessesRecord
  has_many :com_timelines, dependent: :restrict_with_error, inverse_of: :com_timeline_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
