class UserPasskey < ApplicationRecord
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
