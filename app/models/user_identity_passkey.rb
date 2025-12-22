# == Schema Information
#
# Table name: user_identity_passkeys
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :bigint           default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :uuid             not null
#  user_id     :bigint           not null
#  webauthn_id :string           not null
#
# Indexes
#
#  index_user_identity_passkeys_on_user_id  (user_id)
#
class UserIdentityPasskey < IdentityRecord
  MAX_PASSKEYS_PER_USER = 4

  belongs_to :user
  belongs_to :user_identity_passkey_status, optional: true

  validates :webauthn_id, presence: true, uniqueness: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :enforce_user_passkey_limit, on: :create

  before_validation :set_defaults

  private

    def enforce_user_passkey_limit
      return unless user_id

      count = self.class.where(user_id: user_id).count
      return if count < MAX_PASSKEYS_PER_USER

      errors.add(:base, :too_many, message: "exceeds maximum passkeys per user (#{MAX_PASSKEYS_PER_USER})")
    end

    def set_defaults
      self.external_id ||= SecureRandom.uuid
      self.sign_count ||= 0
      self.description = I18n.t("sign.default_passkey_description") if description.blank?
    end
end
