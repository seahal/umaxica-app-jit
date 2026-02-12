# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
# Database name: operator
#
#  id                   :bigint           not null, primary key
#  lock_version         :integer          default(0), not null
#  multi_factor_enabled :boolean          default(FALSE), not null
#  withdrawn_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :string           not null
#  status_id            :bigint           default(2), not null
#
# Indexes
#
#  index_staffs_on_public_id     (public_id) UNIQUE
#  index_staffs_on_status_id     (status_id)
#  index_staffs_on_withdrawn_at  (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => staff_statuses.id)
#

class Staff < OperatorRecord
  # Staff represents an operator accountably for the staff/admin console.
  # It mirrors `User` for identity concerns but is used for staff-scoped access.
  self.ignored_columns += ["admin_id", "webauthn_id"]

  include Withdrawable
  include ::Accountably

  # Human-readable character set excluding: i, o, 0, 1, s, z, g
  # Allowed: a b c d e f h j k l m n p q r t u v w x y 2 3 4 5 6 7 8 9
  PUBLIC_ID_ALPHABET = "abcdefhjklmnpqrtuvwxy23456789".freeze
  PUBLIC_ID_LENGTH = 8

  attribute :status_id, default: StaffStatus::NEYO

  belongs_to :staff_status,
             foreign_key: :status_id,
             inverse_of: :staffs
  has_many :staff_emails,
           dependent: :restrict_with_error,
           inverse_of: :staff
  has_many :staff_telephones,
           dependent: :restrict_with_error,
           inverse_of: :staff
  has_many :staff_passkeys,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_audits,
           -> { where(subject_type: "Staff") },
           foreign_key: :subject_id,
           dependent: :nullify,
           inverse_of: false
  has_many :user_audits,
           as: :actor,
           dependent: :nullify
  has_many :staff_secrets,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_one_time_passwords,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_tokens,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_messages,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_notifications,
           dependent: :destroy,
           inverse_of: :staff
  has_many :staff_admins,
           dependent: :destroy,
           inverse_of: :staff
  has_many :admins,
           class_name: "Admin",
           inverse_of: :staff,
           dependent: :destroy

  validates :public_id,
            presence: true,
            uniqueness: true,
            length: { is: PUBLIC_ID_LENGTH },
            format: {
              with: /\A[abcdefhjklmnpqrtuvwxy23456789]{8}\z/,
              message: :invalid_format,
            }
  validates :status_id, numericality: { only_integer: true }

  before_validation :normalize_public_id
  before_validation :assign_public_id!, on: :create

  def staff?
    true
  end

  def user?
    false
  end

  private

  # Normalize public_id: strip whitespace, remove hyphens/underscores, downcase
  # Examples: "ABCD-EFGH" -> "abcdefgh", " abcd_efgh " -> "abcdefgh"
  def normalize_public_id
    return if public_id.blank?

    self.public_id = public_id.strip.gsub(/[-_]/, "").downcase
  end

  # Assign a unique public_id if not already set
  def assign_public_id!
    return if public_id.present?

    loop do
      self.public_id = generate_public_id
      break unless self.class.exists?(public_id: public_id)
    end
  end

  # Generate a random 8-character public_id from the allowed alphabet
  def generate_public_id
    Array.new(PUBLIC_ID_LENGTH) { PUBLIC_ID_ALPHABET[SecureRandom.random_number(PUBLIC_ID_ALPHABET.length)] }.join
  end
end
