# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contacts
#
#  id               :uuid             not null, primary key
#  public_id        :string(21)       default(""), not null
#  token            :string(32)       default(""), not null
#  token_digest     :string(255)      default(""), not null
#  token_expires_at :timestamptz      default("-infinity"), not null
#  token_viewed     :boolean          default(FALSE), not null
#  ip_address       :inet             default("0.0.0.0"), not null
#  status_id        :string(255)      default("NONE"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :string(255)      default("NONE"), not null
#
# Indexes
#
#  index_com_contacts_on_category_id       (category_id)
#  index_com_contacts_on_public_id         (public_id)
#  index_com_contacts_on_status_id         (status_id)
#  index_com_contacts_on_token             (token)
#  index_com_contacts_on_token_digest      (token_digest)
#  index_com_contacts_on_token_expires_at  (token_expires_at)
#

class ComContact < GuestsRecord
  include ::PublicId

  # Associations
  has_one :com_contact_email, dependent: :destroy
  has_one :com_contact_telephone, dependent: :destroy
  belongs_to :com_contact_category,
             class_name: "ComContactCategory",
             foreign_key: :category_id,
             primary_key: :id,
             inverse_of: :com_contacts
  belongs_to :com_contact_status,
             class_name: "ComContactStatus",
             foreign_key: :status_id,
             inverse_of: :com_contacts
  has_many :com_contact_topics, dependent: :destroy

  attr_accessor :confirm_policy

  after_initialize do
    if new_record?
      self.category_id = "SECURITY_ISSUE" if category_id == "NONE" || category_id.nil?
    end
    self.status_id ||= "NONE"
  end

  # Callbacks
  before_validation { self.category_id = category_id&.upcase }
  before_validation { self.status_id = status_id&.upcase }
  before_create :generate_token

  # Validations
  validates :confirm_policy, acceptance: true
  validates :category_id, length: { maximum: 255 }
  validates :status_id, length: { maximum: 255 }
  validates :token, length: { maximum: 32 }
  validates :token_digest, length: { maximum: 255 }

  # State check methods
  def email_pending?
    status_id == "SET_UP" || status_id == "NULL_COM_STATUS"
  end

  def email_verified?
    status_id == "CHECKED_EMAIL_ADDRESS"
  end

  def phone_verified?
    status_id == "CHECKED_TELEPHONE_NUMBER"
  end

  def completed?
    status_id == "COMPLETED_CONTACT_ACTION"
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
    raise StandardError, "Cannot verify email at this time" unless can_verify_email?

    update!(status_id: "CHECKED_EMAIL_ADDRESS")
  end

  def verify_phone!
    raise StandardError, "Cannot verify phone at this time" unless can_verify_phone?

    update!(status_id: "CHECKED_TELEPHONE_NUMBER")
  end

  def complete!
    raise StandardError, "Cannot complete contact at this time" unless can_complete?

    update!(status_id: "COMPLETED_CONTACT_ACTION")
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
