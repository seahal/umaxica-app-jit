# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contacts
#
#  id               :uuid             not null, primary key
#  description      :text
#  email_address    :string
#  ip_address       :cidr
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class AppContact < GuestsRecord
  # Associations
  has_many :app_contact_emails, dependent: :destroy
  has_many :app_contact_telephones, dependent: :destroy
  belongs_to :app_contact_category,
             class_name: "AppContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :title,
             optional: true,
             inverse_of: :app_contacts
  belongs_to :app_contact_status,
             class_name: "AppContactStatus",
             foreign_key: :contact_status_id,
             optional: true,
             inverse_of: :app_contacts
  has_many :app_contact_topics, dependent: :destroy

  attr_accessor :confirm_policy

  after_initialize :set_default_category_and_status, if: :new_record?
  # Callbacks
  before_validation { self.contact_category_title = contact_category_title&.upcase }
  before_validation { self.contact_status_id = contact_status_id&.upcase }
  before_create :generate_public_id
  before_create :generate_token

  # Validations
  validates :confirm_policy, acceptance: true
  validates :contact_category_title, presence: true

  # State transition helpers
  def email_pending?
    contact_status_id == "SET_UP"
  end

  def email_verified?
    contact_status_id == "CHECKED_EMAIL_ADDRESS"
  end

  def phone_verified?
    contact_status_id == "CHECKED_TELEPHONE_NUMBER"
  end

  def can_verify_email?
    email_pending?
  end

  def can_verify_phone?
    email_verified?
  end

  def can_complete?
    phone_verified?
  end

  def verify_email!
    raise StandardError, "Cannot verify email at this time" unless can_verify_email?
    update!(contact_status_id: "CHECKED_EMAIL_ADDRESS")
  end

  def verify_phone!
    raise StandardError, "Cannot verify phone at this time" unless can_verify_phone?
    update!(contact_status_id: "CHECKED_TELEPHONE_NUMBER")
  end

  def complete!
    raise StandardError, "Cannot complete contact at this time" unless can_complete?
    update!(contact_status_id: "COMPLETED_CONTACT_ACTION")
  end

  # Token management
  def generate_final_token
    raw_token = SecureRandom.alphanumeric(32)
    self.token_digest = Argon2::Password.create(raw_token)
    self.token_expires_at = 7.days.from_now
    self.token_viewed = false
    save!
    raw_token # Return raw token only once
  end

  def verify_token(raw_token)
    return false if token_viewed?
    return false if token_expires_at && Time.current >= token_expires_at
    return false unless token_digest

    if Argon2::Password.verify_password(raw_token, token_digest)
      update!(token_viewed: true)
      true
    else
      false
    end
  end

  def token_expired?
    token_expires_at && Time.current >= token_expires_at
  end

  # Override to_param to use public_id in URLs
  def to_param
    public_id
  end

  private

  def generate_public_id
    self.public_id ||= Nanoid.generate(size: 21)
  end

  def generate_token
    self.token ||= SecureRandom.alphanumeric(32)
  end

  def set_default_category_and_status
    self.contact_category_title ||= "NULL_APP_CATEGORY"
    self.contact_status_id ||= "NULL_APP_STATUS"
  end
end
