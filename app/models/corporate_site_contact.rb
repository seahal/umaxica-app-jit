class CorporateSiteContact < GuestsRecord
  # Associations
  has_many :corporate_site_contact_emails, dependent: :destroy
  has_many :corporate_site_contact_telephones, dependent: :destroy
  has_many :corporate_site_contact_topics, dependent: :destroy

  # # State machine using Rails enum
  # enum :status, {
  #   email_pending: "email_pending",
  #   email_verified: "email_verified",
  #   phone_verified: "phone_verified",
  #   completed: "completed"
  # }, default: :email_pending, validate: true
  #
  # # Category enum
  # enum :category, {
  #   general: "general",
  #   inquiry: "inquiry",
  #   support: "support",
  #   sales: "sales",
  #   partnership: "partnership",
  #   other: "other"
  # }, default: :general, validate: true

  # Validations
  # validates :status, presence: true, inclusion: { in: statuses.keys }
  # validates :category, presence: true, inclusion: { in: categories.keys }

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
end
