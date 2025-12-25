# == Schema Information
#
# Table name: domain_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(253)      default(""), not null
#  status_id  :string(255)      default("NONE"), not null
#  memo       :string(1024)     default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expires_at :datetime         not null
#
# Indexes
#
#  index_domain_occurrences_on_body        (body) UNIQUE
#  index_domain_occurrences_on_expires_at  (expires_at)
#  index_domain_occurrences_on_public_id   (public_id) UNIQUE
#  index_domain_occurrences_on_status_id   (status_id)
#

class DomainOccurrence < UniversalRecord
  include PublicId
  include Occurrence

  belongs_to :domain_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :domain_occurrences
  has_many :area_domain_occurrences, dependent: :destroy
  has_many :area_occurrences, through: :area_domain_occurrences
  has_many :domain_email_occurrences, dependent: :destroy
  has_many :email_occurrences, through: :domain_email_occurrences
  has_many :domain_ip_occurrences, dependent: :destroy
  has_many :ip_occurrences, through: :domain_ip_occurrences
  has_many :domain_staff_occurrences, dependent: :destroy
  has_many :staff_occurrences, through: :domain_staff_occurrences
  has_many :domain_telephone_occurrences, dependent: :destroy
  has_many :telephone_occurrences, through: :domain_telephone_occurrences
  has_many :domain_user_occurrences, dependent: :destroy
  has_many :user_occurrences, through: :domain_user_occurrences
  has_many :domain_zip_occurrences, dependent: :destroy
  has_many :zip_occurrences, through: :domain_zip_occurrences

  validates :body, length: { maximum: 253 }
  validates :status_id, length: { maximum: 255 }
end
