# == Schema Information
#
# Table name: area_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(255)      default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_area_occurrences_on_body        (body) UNIQUE
#  index_area_occurrences_on_expires_at  (expires_at)
#  index_area_occurrences_on_public_id   (public_id) UNIQUE
#  index_area_occurrences_on_status_id   (status_id)
#

class AreaOccurrence < UniversalRecord
  include PublicId

  belongs_to :area_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :area_occurrences

  validates :public_id,
            presence: true,
            length: { is: 21 },
            format: { with: /\A[A-Za-z0-9_-]{21}\z/ },
            uniqueness: true
  validates :body, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :status_id, presence: true, length: { maximum: 255 }
  validates :memo, length: { maximum: 1024 }, allow_nil: true
end
