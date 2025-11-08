# == Schema Information
#
# Table name: user_time_based_one_time_passwords
#
#  time_based_one_time_password_id :binary           not null
#  user_id                         :binary           not null
#
class UserTimeBasedOneTimePassword < IdentitiesRecord
  belongs_to :user
end

# del?
