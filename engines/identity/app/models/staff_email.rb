# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
# Database name: operator
#
#  id                             :bigint           not null, primary key
#  address                        :string           default(""), not null
#  address_bidx                   :string
#  address_digest                 :string
#  locked_at                      :datetime
#  notifiable                     :boolean          default(TRUE), not null
#  otp_attempts_count             :integer          default(0), not null
#  otp_counter                    :text             not null
#  otp_expires_at                 :datetime
#  otp_last_sent_at               :datetime
#  otp_private_key                :string           not null
#  promotional                    :boolean          default(TRUE), not null
#  subscribable                   :boolean          default(TRUE), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  public_id                      :string(21)       default(""), not null
#  staff_id                       :bigint           not null
#  staff_identity_email_status_id :bigint           default(6), not null
#
# Indexes
#
#  index_staff_emails_on_address                         (address)
#  index_staff_emails_on_address_bidx                    (address_bidx) UNIQUE WHERE (address_bidx IS NOT NULL)
#  index_staff_emails_on_address_digest                  (address_digest) UNIQUE WHERE (address_digest IS NOT NULL)
#  index_staff_emails_on_lower_address                   (lower((address)::text)) UNIQUE
#  index_staff_emails_on_public_id                       (public_id) UNIQUE
#  index_staff_emails_on_staff_id                        (staff_id)
#  index_staff_emails_on_staff_identity_email_status_id  (staff_identity_email_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_identity_email_status_id => staff_email_statuses.id)
#

class StaffEmail < OperatorRecord
  alias_attribute :staff_email_status_id, :staff_identity_email_status_id
  include PublicId
  include Email

  self.filter_attributes += %w(address)

  MAX_EMAILS_PER_STAFF = 4
  attribute :staff_identity_email_status_id, default: StaffEmailStatus::UNVERIFIED
  belongs_to :staff_email_status, inverse_of: :staff_emails, foreign_key: :staff_identity_email_status_id
  belongs_to :staff
  validates :address, presence: true, length: { maximum: 255 }
  validates :address, uniqueness: { case_sensitive: false }
  validates :address_bidx,
            uniqueness: { conditions: -> { where.not(address_bidx: nil) } },
            allow_nil: true
  validates :address_digest,
            uniqueness: { conditions: -> { where.not(address_digest: nil) } },
            allow_nil: true
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :staff_identity_email_status_id,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :ensure_unique_address_digest
  validate :enforce_staff_email_limit, on: :create
  before_validation :set_address_digests
  before_destroy :prevent_destroy_when_undeletable
  before_validation do
    self.staff_id ||= 0
  end

  encrypts :address, downcase: true, deterministic: true

  def to_param
    public_id
  end

  # Returns true if this email is protected from deletion (e.g., OAuth-linked)
  def undeletable?
    staff_identity_email_status_id == StaffEmailStatus::OAUTH_LINKED
  end

  private

  def set_address_digests
    digest = IdentifierBlindIndex.bidx_for_email(raw_address)
    self.address_bidx = digest
    self.address_digest = digest if respond_to?(:address_digest=)
  end

  def ensure_unique_address_digest
    return if address_digest.blank?
    return unless self.class.where(address_digest: address_digest).where.not(id: id).exists?

    errors.add(:address, :taken)
  end

  def prevent_destroy_when_undeletable
    return unless staff_identity_email_status_id == StaffEmailStatus::OAUTH_LINKED

    errors.add(:base, :undeletable, message: "cannot delete a protected email address")
    throw(:abort)
  end

  def enforce_staff_email_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_EMAILS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum emails per staff (#{MAX_EMAILS_PER_STAFF})")
  end
end
