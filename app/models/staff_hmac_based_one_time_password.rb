# == Schema Information
#
# Table name: staff_hmac_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  hmac_based_one_time_password_id :binary           not null
#  staff_id                        :binary           not null
#
class StaffHmacBasedOneTimePassword < AccountsRecord
  belongs_to :staff
  belongs_to :hmac_based_one_time_password
end
