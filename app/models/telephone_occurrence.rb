# frozen_string_literal: true

# == Schema Information
#
# Table name: telephone_occurrences
# Database name: occurrence
#
#  id         :bigint           not null, primary key
#  body       :string           default(""), not null
#  expires_at :datetime         not null
#  memo       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string(21)       default(""), not null
#  status_id  :bigint           default(2), not null
#
# Indexes
#
#  index_telephone_occurrences_on_body        (body) UNIQUE
#  index_telephone_occurrences_on_expires_at  (expires_at)
#  index_telephone_occurrences_on_public_id   (public_id) UNIQUE
#  index_telephone_occurrences_on_status_id   (status_id)
#
# Foreign Keys
#
#  fk_telephone_occurrences_on_status_id  (status_id => telephone_occurrence_statuses.id)
#

class TelephoneOccurrence < OccurrenceRecord
  include PublicId
  include Occurrence
  include TelephoneNormalization

  attribute :status_id, default: TelephoneOccurrenceStatus::NEYO

  # E.164 normalization and validation for body field
  normalize_telephone_field :body

  belongs_to :telephone_occurrence_status, foreign_key: :status_id, optional: true, inverse_of: :telephone_occurrences
  has_many :area_telephone_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :area_occurrences, through: :area_telephone_occurrences
  has_many :domain_telephone_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :domain_occurrences, through: :domain_telephone_occurrences
  has_many :email_telephone_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :email_occurrences, through: :email_telephone_occurrences
  has_many :ip_telephone_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :ip_occurrences, through: :ip_telephone_occurrences
  has_many :staff_telephone_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :staff_occurrences, through: :staff_telephone_occurrences
  has_many :telephone_user_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :user_occurrences, through: :telephone_user_occurrences
  has_many :telephone_zip_occurrences, dependent: :destroy, inverse_of: :telephone_occurrence
  has_many :zip_occurrences, through: :telephone_zip_occurrences

  # Note: body validation is now handled by TelephoneNormalization (E.164 format)
  validates :status_id, numericality: { only_integer: true }
end
