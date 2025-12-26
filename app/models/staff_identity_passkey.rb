# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_passkeys
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  description :string           default(""), not null
#  external_id :uuid             not null
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  staff_id    :uuid             not null
#  updated_at  :datetime         not null
#  webauthn_id :binary           not null
#
# Indexes
#
#  index_staff_identity_passkeys_on_staff_id     (staff_id)
#  index_staff_identity_passkeys_on_webauthn_id  (webauthn_id) UNIQUE
#

class StaffIdentityPasskey < IdentityRecord
  MAX_PASSKEYS_PER_STAFF = 4

  belongs_to :staff

  validates :webauthn_id, presence: true, uniqueness: true
  validates :external_id, presence: true
  validates :public_key, presence: true
  validates :description, presence: true
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
