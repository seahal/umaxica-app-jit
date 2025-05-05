# == Schema Information
#
# Table name: service_site_contacts
#
#  id               :bigint           not null, primary key
#  description      :text
#  email_address    :string
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ServiceSiteContact < ContactsRecord
  attr_accessor :confirm_policy

  before_save { self.email_address&.downcase! }

  encrypts :email_address, downcase: true
  encrypts :telephone_number, downcase: true
  encrypts :title
  encrypts :description

  validates :confirm_policy, acceptance: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP },
            presence: true
  validates :telephone_number,
            presence: true
end
