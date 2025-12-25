# == Schema Information
#
# Table name: zip_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(16)       default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_zip_occurrences_on_body        (body) UNIQUE
#  index_zip_occurrences_on_expires_at  (expires_at)
#  index_zip_occurrences_on_public_id   (public_id) UNIQUE
#  index_zip_occurrences_on_status_id   (status_id)
#

class ZipOccurrence < UniversalRecord
  include PublicId

  belongs_to :zip_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :zip_occurrences
  has_many :area_zip_occurrences, dependent: :destroy
  has_many :area_occurrences, through: :area_zip_occurrences
  has_many :domain_zip_occurrences, dependent: :destroy
  has_many :domain_occurrences, through: :domain_zip_occurrences
  has_many :email_zip_occurrences, dependent: :destroy
  has_many :email_occurrences, through: :email_zip_occurrences
  has_many :ip_zip_occurrences, dependent: :destroy
  has_many :ip_occurrences, through: :ip_zip_occurrences
  has_many :staff_zip_occurrences, dependent: :destroy
  has_many :staff_occurrences, through: :staff_zip_occurrences
  has_many :telephone_zip_occurrences, dependent: :destroy
  has_many :telephone_occurrences, through: :telephone_zip_occurrences
  has_many :user_zip_occurrences, dependent: :destroy
  has_many :user_occurrences, through: :user_zip_occurrences

  validates :public_id,
            presence: true,
            length: { is: 21 },
            format: { with: /\A[A-Za-z0-9_-]{21}\z/ },
            uniqueness: true
  validates :body, presence: true, uniqueness: true, length: { maximum: 16 }
  validates :status_id, presence: true, length: { maximum: 255 }
  validates :memo, length: { maximum: 1024 }, allow_nil: true
end
