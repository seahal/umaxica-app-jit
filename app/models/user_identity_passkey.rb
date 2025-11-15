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
#  webauthn_id :uuid             not null
#
# Indexes
#
#  index_user_identity_passkeys_on_user_id  (user_id)
#
class UserIdentityPasskey < IdentityRecord
  belongs_to :user

  validates :webauthn_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_defaults

  private

  def set_defaults
    self.sign_count ||= 0
    self.description = I18n.t("sign.default_passkey_description") if description.blank?
  end
end
