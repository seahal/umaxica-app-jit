# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_passkeys
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :bigint           default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :uuid             not null
#  staff_id    :bigint           not null
#  webauthn_id :binary           not null
#
# Indexes
#
#  index_staff_identity_passkeys_on_staff_id  (staff_id)
#
class StaffIdentityPasskey < IdentityRecord
  MAX_PASSKEYS_PER_STAFF = 4

  belongs_to :staff

  validate :enforce_staff_passkey_limit, on: :create

  private

  def enforce_staff_passkey_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_PASSKEYS_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum passkeys per staff (#{MAX_PASSKEYS_PER_STAFF})")
  end
end
