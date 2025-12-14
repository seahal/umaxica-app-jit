# frozen_string_literal: true

class OrgContact < GuestsRecord
  # Associations
  has_many :org_contact_emails, dependent: :destroy
  has_many :org_contact_telephones, dependent: :destroy
  belongs_to :org_contact_category,
             class_name: "OrgContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :title,
             optional: true,
             inverse_of: :org_contacts
  belongs_to :org_contact_status,
             class_name: "OrgContactStatus",
             foreign_key: :contact_status_id,
             optional: true,
             inverse_of: :org_contacts
  has_many :org_contact_topics, dependent: :destroy

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
    self.contact_category_title ||= "NULL_ORG_CATEGORY"
    self.contact_status_id ||= "NULL_ORG_STATUS"
  end
end
