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
  belongs_to :app_contact_email
  belongs_to :app_contact_telephone
  belongs_to :app_contact_category,
             class_name: "AppContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :title,
             optional: true,
             inverse_of: :app_contacts
  belongs_to :app_contact_status,
             class_name: "AppContactStatus",
             foreign_key: :contact_status_title,
             primary_key: :title,
             optional: true,
             inverse_of: :app_contacts
  has_many :app_contact_topics, dependent: :destroy

  attr_accessor :confirm_policy

  # Callbacks
  after_initialize :set_default_category_and_status, if: :new_record?

  # Validations
  validates :confirm_policy, acceptance: true
  validates :contact_category_title, presence: true

  # State transition helpers
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
    return false unless can_verify_email?
    update!(status: :email_verified)
  end

  def verify_phone!
    return false unless can_verify_phone?
    update!(status: :phone_verified)
  end

  def complete!
    return false unless can_complete?
    update!(status: :completed)
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

  private

  def set_default_category_and_status
    self.contact_category_title ||= "NULL_APP_CATEGORY"
    self.contact_status_title ||= "NULL_APP_STATUS"
  end
end
