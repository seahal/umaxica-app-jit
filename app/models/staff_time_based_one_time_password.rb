# == Schema Information
#
# Table name: staff_time_based_one_time_passwords
#
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  staff_id                        :uuid             not null
#  time_based_one_time_password_id :uuid             not null
#
class StaffTimeBasedOneTimePassword < IdentifiersRecord
  belongs_to :staff
end
