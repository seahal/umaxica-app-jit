# == Schema Information
#
# Table name: app_contacts
#
#  id                     :uuid             not null, primary key
#  contact_category_title :string(255)      default("APPLICATION_INQUIRY"), not null
#  contact_status_id      :string(255)      default("NONE"), not null
#  created_at             :datetime         not null
#  ip_address             :inet             default("0.0.0.0"), not null
#  public_id              :string(21)       default(""), not null
#  token                  :string(32)       default(""), not null
#  token_digest           :string(255)      default(""), not null
#  token_expires_at       :timestamptz      default("-infinity"), not null
#  token_viewed           :boolean          default(FALSE), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_app_contacts_on_contact_category_title  (contact_category_title)
#  index_app_contacts_on_contact_status_id       (contact_status_id)
#  index_app_contacts_on_public_id               (public_id)
#  index_app_contacts_on_token                   (token)
#  index_app_contacts_on_token_digest            (token_digest)
#  index_app_contacts_on_token_expires_at        (token_expires_at)
#

class AppContact < GuestsRecord
  include ::PublicId

  # Associations
  belongs_to :app_contact_category,
             class_name: "AppContactCategory",
             foreign_key: :contact_category_title,
             primary_key: :id,
             inverse_of: :app_contacts
  belongs_to :app_contact_status,
             class_name: "AppContactStatus",
             foreign_key: :contact_status_id,
             inverse_of: :app_contacts
  has_many :app_contact_topics, dependent: :destroy
  has_many :app_contact_emails, dependent: :destroy
  has_many :app_contact_telephones, dependent: :destroy

  attr_accessor :confirm_policy

  after_initialize do
    self.contact_category_title ||= "APPLICATION_INQUIRY"
    self.contact_status_id ||= "NONE"
  end

  # Callbacks
  before_validation { self.contact_category_title = contact_category_title&.upcase }
  before_validation { self.contact_status_id = contact_status_id&.upcase }
  before_create :generate_token

  # Validations
  validates :confirm_policy, acceptance: true

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
    return false if token_expires_at.to_s == "-Infinity"

    token_expires_at && Time.current >= token_expires_at
  end

  # Override to_param to use public_id in URLs
  def to_param
    public_id
  end

  private

    def generate_token
      self.token ||= SecureRandom.alphanumeric(32)
    end
end
