# == Schema Information
#
# Table name: user_identity_passkeys
#
#  id                              :uuid             not null, primary key
#  created_at                      :datetime         not null
#  description                     :string           default(""), not null
#  external_id                     :uuid             not null
#  public_key                      :text             not null
#  sign_count                      :integer          default(0), not null
#  updated_at                      :datetime         not null
#  user_id                         :uuid             not null
#  user_identity_passkey_status_id :string(255)      default("ACTIVE"), not null
#  webauthn_id                     :string           default(""), not null
#
# Indexes
#
#  idx_on_user_identity_passkey_status_id_f979a7d699  (user_identity_passkey_status_id)
#  index_user_identity_passkeys_on_user_id            (user_id)
#  index_user_identity_passkeys_on_webauthn_id        (webauthn_id) UNIQUE
#

class UserIdentityPasskey < IdentityRecord
  MAX_PASSKEYS_PER_USER = 4

  belongs_to :user
  belongs_to :user_identity_passkey_status, optional: true

  validates :webauthn_id, presence: true, uniqueness: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :user_identity_passkey_status_id, length: { maximum: 255 }
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
