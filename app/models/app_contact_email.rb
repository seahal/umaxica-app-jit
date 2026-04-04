# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_emails
# Database name: guest
#
#  id             :bigint           not null, primary key
#  email_address  :string(1000)     default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  app_contact_id :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_emails_on_app_contact_id  (app_contact_id)
#  index_app_contact_emails_on_email_address   (email_address)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#
class AppContactEmail < GuestRecord
  belongs_to :app_contact, inverse_of: :app_contact_emails

  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true
end
