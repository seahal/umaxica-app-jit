# == Schema Information
#
# Table name: passkey_for_staffs
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
#  index_passkey_for_staffs_on_staff_id  (staff_id)
#
class PasskeyForStaff < IdentityRecord
  belongs_to :staff
end
