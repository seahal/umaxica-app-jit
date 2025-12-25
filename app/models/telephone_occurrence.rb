# == Schema Information
#
# Table name: telephone_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(32)       default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_telephone_occurrences_on_body        (body) UNIQUE
#  index_telephone_occurrences_on_expires_at  (expires_at)
#  index_telephone_occurrences_on_public_id   (public_id) UNIQUE
#  index_telephone_occurrences_on_status_id   (status_id)
#

class TelephoneOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :telephone_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :telephone_occurrences
  has_many :area_telephone_occurrences, dependent: :destroy
  has_many :area_occurrences, through: :area_telephone_occurrences
  has_many :domain_telephone_occurrences, dependent: :destroy
  has_many :domain_occurrences, through: :domain_telephone_occurrences
  has_many :email_telephone_occurrences, dependent: :destroy
  has_many :email_occurrences, through: :email_telephone_occurrences
  has_many :ip_telephone_occurrences, dependent: :destroy
  has_many :ip_occurrences, through: :ip_telephone_occurrences
  has_many :staff_telephone_occurrences, dependent: :destroy
  has_many :staff_occurrences, through: :staff_telephone_occurrences
  has_many :telephone_user_occurrences, dependent: :destroy
  has_many :user_occurrences, through: :telephone_user_occurrences
  has_many :telephone_zip_occurrences, dependent: :destroy
  has_many :zip_occurrences, through: :telephone_zip_occurrences

  validates :body, length: { maximum: 32 }
  validates :status_id, length: { maximum: 255 }
end
