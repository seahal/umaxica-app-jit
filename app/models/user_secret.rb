# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secrets
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
#  uses_remaining                 :integer          default(1), not null
#  user_secret_kind_id            :string(255)      not null
#
# Indexes
#
#  index_user_secrets_on_expires_at                      (expires_at)
#  index_user_secrets_on_user_id                         (user_id)
#  index_user_secrets_on_user_identity_secret_status_id  (user_identity_secret_status_id)
#  index_user_secrets_on_user_secret_kind_id             (user_secret_kind_id)
#

class UserSecret < PrincipalRecord
  alias_attribute :user_secret_status_id, :user_identity_secret_status_id
  include ::Secret
  include UserSecret::Kinds

  MAX_SECRETS_PER_USER = 10
  attr_accessor :raw_secret

  belongs_to :user, inverse_of: :user_secrets
  belongs_to :user_secret_status, inverse_of: :user_secrets, foreign_key: :user_identity_secret_status_id
  belongs_to :user_secret_kind, inverse_of: :user_secrets

  validates :name, length: { maximum: 255 }
  validates :password_digest, presence: true, length: { maximum: 255 }
  validates :user_identity_secret_status_id, length: { maximum: 255 }
  validates :user_secret_kind_id, length: { maximum: 255 }

  validate :enforce_secret_limit, on: :create

  def self.identity_secret_status_class
    UserSecretStatus
  end

  def self.identity_secret_status_id_column
    :user_identity_secret_status_id
  end

  def self.generate_raw_secret(length: SECRET_PASSWORD_LENGTH)
    SecureRandom.base58(length)
  end

  # Alias for password to match controller params
  def value=(val)
    self.password = val
  end

  def value
    password
  end

  def enabled?
    active?
  end

  private

  def enforce_secret_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_SECRETS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum secrets per user (#{MAX_SECRETS_PER_USER})")
  end
end
