# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_telephones
# Database name: guest
#
#  id                      :bigint           not null, primary key
#  hotp_counter            :integer
#  hotp_secret             :string
#  telephone_number        :string(1000)     default(""), not null
#  telephone_number_bidx   :string
#  telephone_number_digest :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  com_contact_id          :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id_unique    (com_contact_id) UNIQUE
#  index_com_contact_telephones_on_telephone_number         (telephone_number)
#  index_com_contact_telephones_on_telephone_number_bidx    (telephone_number_bidx) UNIQUE WHERE (telephone_number_bidx IS NOT NULL)
#  index_com_contact_telephones_on_telephone_number_digest  (telephone_number_digest) UNIQUE WHERE (telephone_number_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :com_contact, inverse_of: :com_contact_telephone

  # E.164 normalization and validation
  normalize_telephone_field :telephone_number

  validates :com_contact_id, uniqueness: true
  validates :telephone_number_bidx,
            uniqueness: { conditions: -> { where.not(telephone_number_bidx: nil) } },
            allow_nil: true
  validates :telephone_number_digest,
            uniqueness: { conditions: -> { where.not(telephone_number_digest: nil) } },
            allow_nil: true
  validate :ensure_unique_telephone_number_digest

  before_validation :set_telephone_number_digests
  encrypts :telephone_number, deterministic: true

  private

  def set_telephone_number_digests
    digest = IdentifierBlindIndex.bidx_for_telephone(telephone_number)
    self.telephone_number_bidx = digest
    self.telephone_number_digest = digest if respond_to?(:telephone_number_digest=)
  end

  def ensure_unique_telephone_number_digest
    return if telephone_number_digest.blank?
    return unless self.class.where(telephone_number_digest: telephone_number_digest).where.not(id: id).exists?

    errors.add(:telephone_number, :taken)
  end
end
