# == Schema Information
#
# Table name: service_site_contacts
#
#  id               :uuid             not null, primary key
#  description      :text
#  email_address    :string
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ServiceSiteContact < ContactsRecord
  attr_accessor :confirm_policy, :email_pass_code, :telephone_pass_code, :step

  before_validation { self.step ||= "introduction" }
  before_save { self.email_address&.downcase! }
  before_save { self.telephone_number&.downcase! }

  encrypts :email_address, downcase: true
  encrypts :telephone_number, downcase: true
  encrypts :title
  encrypts :description

  validates :step,
            presence: true
  validates :confirm_policy,
            acceptance: true,
            unless: Proc.new { it.telephone_number.nil? && it.confirm_policy.nil? && it.email_address.nil? }
  validates :email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            presence: true,
            unless: Proc.new { it.telephone_number.nil? && it.confirm_policy.nil? && it.email_address.nil? }
  validates :telephone_number,
            presence: true,
            format: { with: /\A\+[1-9]\d{1,14}\z/ },
            unless: Proc.new { it.telephone_number.nil? && it.confirm_policy.nil? && it.email_address.nil? }
  validates :email_pass_code,
            numericality: { only_integer: true },
            length: { is: 6 },
            presence: true,
            unless: Proc.new { it.email_pass_code.nil? },
            if: Proc.new { it.telephone_pass_code.nil? }
  validates :telephone_pass_code,
            numericality: { only_integer: true },
            length: { is: 6 },
            presence: true,
            unless: Proc.new { it.telephone_pass_code.nil? }
  validates :title,
            presence: true,
            length: { in: 8...256 },
            unless: Proc.new { it.title.nil? }
  validates :description,
            presence: true,
            length: { in: 8...1024 },
            unless: Proc.new { it.description.nil? }
end
