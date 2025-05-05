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

  validates :confirm_policy,
            acceptance: true,
            on: :create
  validates :email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            presence: true,
            on: :create
  validates :telephone_number,
            presence: true,
            on: :create
  # validates :email_pass_code, numericality: { only_integer: true },
  #           length: { is: 6 },
  #           presence: true,
  #           unless: Proc.new { |a| a.pass_code.nil? && !a.number.nil? }
  # validates :telephone_pass_code, numericality: { only_integer: true },
  #           length: { is: 6 },
  #           presence: true,
  #           unless: Proc.new { |a| a.pass_code.nil? && !a.number.nil?
end
