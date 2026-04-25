# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_emails
# Database name: guest
#
#  id                   :bigint           not null, primary key
#  email_address        :string(1000)     default(""), not null
#  email_address_bidx   :string
#  email_address_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  app_contact_id       :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_emails_on_app_contact_id        (app_contact_id)
#  index_app_contact_emails_on_email_address         (email_address)
#  index_app_contact_emails_on_email_address_bidx    (email_address_bidx) UNIQUE WHERE (email_address_bidx IS NOT NULL)
#  index_app_contact_emails_on_email_address_digest  (email_address_digest) UNIQUE WHERE (email_address_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#
class AppContactEmail < GuestRecord
  belongs_to :app_contact, inverse_of: :app_contact_emails

  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email_address_bidx,
            uniqueness: { conditions: -> { where.not(email_address_bidx: nil) } },
            allow_nil: true
  validates :email_address_digest,
            uniqueness: { conditions: -> { where.not(email_address_digest: nil) } },
            allow_nil: true
  validate :ensure_unique_email_address_digest

  before_validation :set_email_address_digests
  before_save { email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true

  private

  def set_email_address_digests
    digest = IdentifierBlindIndex.bidx_for_email(email_address)
    self.email_address_bidx = digest
    self.email_address_digest = digest if respond_to?(:email_address_digest=)
  end

  def ensure_unique_email_address_digest
    return if email_address_digest.blank?
    return unless self.class.where(email_address_digest: email_address_digest).where.not(id: id).exists?

    errors.add(:email_address, :taken)
  end
end
