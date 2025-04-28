# == Schema Information
#
# Table name: staff_time_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  staff_id                        :binary           not null
#  time_based_one_time_password_id :binary           not null
#
class StaffTimeBasedOneTimePassword < AccountsRecord
  belongs_to :staff
end
