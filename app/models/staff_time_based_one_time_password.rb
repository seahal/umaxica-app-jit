class StaffTimeBasedOneTimePassword < ApplicationRecord
  belongs_to :staff
  belongs_to :time_based_one_time_password
end
