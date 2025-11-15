class ComContact < GuestsRecord
  # Associations
  has_many :com_contact_emails, dependent: :destroy
  has_many :com_contact_telephones, dependent: :destroy
  belongs_to :com_contact_category,
             class_name: "ComContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :title,
             optional: true,
             inverse_of: :com_contacts
  belongs_to :com_contact_status,
             class_name: "ComContactStatus",
             foreign_key: :contact_status_title,
             primary_key: :title,
             optional: true,
             inverse_of: :com_contacts
  has_many :com_contact_topics, dependent: :destroy

  attr_accessor :confirm_policy

  after_initialize :set_default_category_and_status, if: :new_record?
  # Callbacks
  before_create :generate_public_id
  before_create :generate_token

  # Validations
  validates :confirm_policy, acceptance: true
  validates :contact_category_title, presence: true

  # State transition helpers

  # State check methods
  def email_pending?
    contact_status_title == "SET_UP" || contact_status_title == "NULL_COM_STATUS"
  end

  def email_verified?
    contact_status_title == "CHECKED_EMAIL_ADDRESS"
  end

  def phone_verified?
    contact_status_title == "CHECKED_TELEPHONE_NUMBER"
  end

  def completed?
    contact_status_title == "COMPLETED_CONTACT_ACTION"
  end

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
    update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
  end

  def verify_phone!
    return false unless can_verify_phone?
    update!(contact_status_title: "CHECKED_TELEPHONE_NUMBER")
  end

  def complete!
    return false unless can_complete?
    update!(contact_status_title: "COMPLETED_CONTACT_ACTION")
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

  def generate_public_id
    self.public_id ||= Nanoid.generate(size: 21)
  end

  def generate_token
    self.token ||= SecureRandom.alphanumeric(32)
  end

  def set_default_category_and_status
    self.contact_category_title ||= "NULL_COM_CATEGORY"
    self.contact_status_title ||= "NULL_COM_STATUS"
  end
end
