# == Schema Information
#
# Table name: user_identity_secrets
#
#  id                             :uuid             not null, primary key
#  created_at                     :datetime         not null
#  expires_at                     :datetime         default("infinity"), not null
#  last_used_at                   :datetime         default("-infinity"), not null
#  name                           :string           default(""), not null
#  password_digest                :string           default(""), not null
#  updated_at                     :datetime         not null
#  user_id                        :uuid             not null
#  user_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  index_user_identity_secrets_on_expires_at                      (expires_at)
#  index_user_identity_secrets_on_user_id                         (user_id)
#  index_user_identity_secrets_on_user_identity_secret_status_id  (user_identity_secret_status_id)
#

class UserIdentitySecret < IdentitiesRecord
  MAX_SECRETS_PER_USER = 10

  belongs_to :user
  belongs_to :user_identity_secret_status

  has_secure_password algorithm: :argon2

  validates :name, presence: true, length: { maximum: 255 }
  validates :password_digest, presence: true, length: { maximum: 255 }
  validates :user_identity_secret_status_id, length: { maximum: 255 }

  validate :enforce_user_secret_limit, on: :create

  # Alias for password to match controller params
  def value=(val)
    self.password = val
  end

  def value
    password
  end

  private

    def enforce_user_secret_limit
      return unless user_id

      count = UserIdentitySecret.where(user_id: user_id).count
      return if count < MAX_SECRETS_PER_USER

      errors.add(:base, :too_many, message: "exceeds maximum secrets per user (#{MAX_SECRETS_PER_USER})")
    end
end
