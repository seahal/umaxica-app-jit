# == Schema Information
#
# Table name: org_timeline_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OrgTimelineStatus < BusinessesRecord
  has_many :org_timelines, dependent: :restrict_with_error, inverse_of: :org_timeline_status

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }
end
