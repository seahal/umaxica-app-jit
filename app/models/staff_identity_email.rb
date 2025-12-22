# == Schema Information
#
# Table name: staff_identity_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#  staff_identity_email_status_id :string
#
# Indexes
#
#  index_staff_identity_emails_on_staff_id  (staff_id)
#  index_staff_identity_emails_on_staff_identity_email_status_id  (staff_identity_email_status_id)
#
class StaffIdentityEmail < IdentitiesRecord
  include SetId
  include Email

  MAX_EMAILS_PER_STAFF = 4

  belongs_to :staff_identity_email_status, optional: true
  belongs_to :staff, optional: true

  encrypts :address, deterministic: true

  validate :enforce_staff_email_limit, on: :create

  private

    def enforce_staff_email_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_EMAILS_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum emails per staff (#{MAX_EMAILS_PER_STAFF})")
    end
end
