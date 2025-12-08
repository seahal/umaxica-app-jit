# == Schema Information
#
# Table name: user_identity_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
class UserIdentityOneTimePassword < IdentitiesRecord
  belongs_to :user
  belongs_to :hmac_based_one_time_password
end

# del?
