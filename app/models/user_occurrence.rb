# frozen_string_literal: true

# == Schema Information
#
# Table name: user_occurrences
#
#  id         :uuid             not null, primary key
#  public_id  :string(21)       default(""), not null
#  body       :string(36)       default(""), not null
#  status_id  :string(255)      default("NEYO"), not null
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
  has_many :area_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :area_occurrences, through: :area_user_occurrences
  has_many :domain_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :domain_occurrences, through: :domain_user_occurrences
  has_many :email_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :email_occurrences, through: :email_user_occurrences
  has_many :ip_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :ip_occurrences, through: :ip_user_occurrences
  has_many :staff_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :staff_occurrences, through: :staff_user_occurrences
  has_many :telephone_user_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :telephone_occurrences, through: :telephone_user_occurrences
  has_many :user_zip_occurrences, dependent: :destroy, inverse_of: :user_occurrence
  has_many :zip_occurrences, through: :user_zip_occurrences

  validates :body, length: { maximum: 36 }
  validates :status_id, length: { maximum: 255 }
end
