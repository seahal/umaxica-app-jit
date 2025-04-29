# == Schema Information
#
# Table name: user_hmac_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
class UserHmacBasedOneTimePassword < AccountsRecord
  belongs_to :user
  belongs_to :hmac_based_one_time_password
end

# del?