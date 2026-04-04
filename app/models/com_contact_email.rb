# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_emails
# Database name: guest
#
#  id             :bigint           not null, primary key
#  email_address  :string(1000)     default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  com_contact_id :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_emails_on_com_contact_id_unique  (com_contact_id) UNIQUE
#  index_com_contact_emails_on_email_address          (email_address)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactEmail < GuestRecord
  belongs_to :com_contact, inverse_of: :com_contact_email

  # Validations
  validates :email_address, presence: true, length: { maximum: 1000 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :com_contact_id, uniqueness: true

  before_save { email_address&.downcase! }
  encrypts :email_address, downcase: true, deterministic: true
end
