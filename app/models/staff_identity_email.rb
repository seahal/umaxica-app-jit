# frozen_string_literal: true

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

  belongs_to :staff_identity_email_status, optional: true
  belongs_to :staff, optional: true

  encrypts :address, deterministic: true
end
