# == Schema Information
#
# Table name: user_identity_emails
#
#  id                            :uuid             not null, primary key
#  address                       :string           default(""), not null
#  created_at                    :datetime         not null
#  locked_at                     :datetime         default("-infinity"), not null
#  otp_attempts_count            :integer          default(0), not null
#  otp_counter                   :text             default(""), not null
#  otp_expires_at                :datetime         default("-infinity"), not null
#  otp_last_sent_at              :datetime         default("-infinity"), not null
#  otp_private_key               :string           default(""), not null
#  updated_at                    :datetime         not null
#  user_id                       :uuid             not null
#  user_identity_email_status_id :string(255)      default("UNVERIFIED"), not null
#
# Indexes
#
#  index_user_identity_emails_on_otp_last_sent_at               (otp_last_sent_at)
#  index_user_identity_emails_on_user_id                        (user_id)
#  index_user_identity_emails_on_user_identity_email_status_id  (user_identity_email_status_id)
#

class UserIdentityEmail < IdentitiesRecord
  include SetId
  include Email
  include Turnstile

  MAX_EMAILS_PER_USER = 4

  belongs_to :user_identity_email_status
  belongs_to :user

  before_validation do
    self.user_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.address ||= ""
  end

  encrypts :address, deterministic: true

  validates :address, presence: true, length: { maximum: 255 }, unless: -> { pass_code.present? }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :user_identity_email_status_id, length: { maximum: 255 }

  validate :enforce_user_email_limit, on: :create

  private

    def enforce_user_email_limit
      return unless user_id

      count = self.class.where(user_id: user_id).count
      return if count < MAX_EMAILS_PER_USER

      errors.add(:base, :too_many, message: "exceeds maximum emails per user (#{MAX_EMAILS_PER_USER})")
    end
end
