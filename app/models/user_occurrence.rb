# == Schema Information
#
# Table name: user_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(36)       default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_user_occurrences_on_body        (body) UNIQUE
#  index_user_occurrences_on_expires_at  (expires_at)
#  index_user_occurrences_on_public_id   (public_id) UNIQUE
#  index_user_occurrences_on_status_id   (status_id)
#

class UserOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :user_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :user_occurrences

  validates :body, length: { maximum: 36 }
  validates :status_id, length: { maximum: 255 }
end
