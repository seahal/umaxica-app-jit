# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_emails
#
#  id                             :uuid             not null, primary key
#  address                        :string           default(""), not null
#  created_at                     :datetime         not null
#  locked_at                      :datetime         default("-infinity"), not null
#  otp_attempts_count             :integer          default(0), not null
#  otp_counter                    :text             default(""), not null
#  otp_expires_at                 :datetime         default("-infinity"), not null
#  otp_last_sent_at               :datetime         default("-infinity"), not null
#  otp_private_key                :string           default(""), not null
#  staff_id                       :uuid             not null
#  staff_identity_email_status_id :string(255)      default("UNVERIFIED"), not null
#  updated_at                     :datetime         not null
#
# Indexes
#
#  index_staff_identity_emails_on_otp_last_sent_at                (otp_last_sent_at)
#  index_staff_identity_emails_on_staff_id                        (staff_id)
#  index_staff_identity_emails_on_staff_identity_email_status_id  (staff_identity_email_status_id)
#

class StaffIdentityEmail < IdentitiesRecord
  include SetId
  include Email

  MAX_EMAILS_PER_STAFF = 4

  belongs_to :staff_identity_email_status
  belongs_to :staff

  before_validation do
    self.staff_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.address ||= ""
  end

  encrypts :address, deterministic: true

  validates :address, presence: true, length: { maximum: 255 }, unless: -> { pass_code.present? }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :staff_identity_email_status_id, length: { maximum: 255 }

  validate :enforce_staff_email_limit, on: :create

  private

  def enforce_staff_email_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_EMAILS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum emails per staff (#{MAX_EMAILS_PER_STAFF})")
  end
end
