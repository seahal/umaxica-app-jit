# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_emails
# Database name: guest
#
#  id             :bigint           not null, primary key
#  email_address  :string(1000)     default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  org_contact_id :bigint           default(0), not null
#
# Indexes
#
#  index_org_contact_emails_on_email_address   (email_address)
#  index_org_contact_emails_on_org_contact_id  (org_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#

class OrgContactEmail < GuestRecord
  belongs_to :org_contact, inverse_of: :org_contact_emails

  # Validations
  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  before_save { email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true
end
