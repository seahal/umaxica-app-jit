# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_passkeys
#
#  id                               :uuid             not null, primary key
#  staff_id                         :uuid             not null
#  webauthn_id                      :binary           not null
#  public_key                       :text             not null
#  description                      :string           default(""), not null
#  sign_count                       :integer          default(0), not null
#  external_id                      :uuid             not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  staff_identity_passkey_status_id :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  idx_on_staff_identity_passkey_status_id_159c890738  (staff_identity_passkey_status_id)
#  index_staff_identity_passkeys_on_staff_id           (staff_id)
#  index_staff_identity_passkeys_on_webauthn_id        (webauthn_id) UNIQUE
#

class StaffIdentityPasskey < IdentityRecord
  MAX_PASSKEYS_PER_STAFF = 4

  belongs_to :staff
  belongs_to :staff_identity_passkey_status, optional: true

  validates :webauthn_id, presence: true, uniqueness: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :description, presence: true
  validates :staff_identity_passkey_status_id, length: { maximum: 255 }
  validates :sign_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :enforce_staff_passkey_limit, on: :create

  private

  def enforce_staff_passkey_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_PASSKEYS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum passkeys per staff (#{MAX_PASSKEYS_PER_STAFF})")
  end
end
