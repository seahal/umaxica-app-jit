# == Schema Information
#
# Table name: passkey_for_users
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
#  index_passkey_for_users_on_user_id  (user_id)
#
class PasskeyForUser < IdentifierRecord
  belongs_to :user
end
