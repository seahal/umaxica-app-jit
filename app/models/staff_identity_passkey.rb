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
  belongs_to :staff
end
