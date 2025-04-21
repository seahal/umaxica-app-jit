class UserTimeBasedOneTimePassword < ApplicationRecord
  belongs_to :user
  belongs_to :time_based_one_time_password
end
