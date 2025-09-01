# == Schema Information
#
# Table name: time_based_one_time_passwords
#
#  id          :uuid             not null, primary key
#  last_otp_at :datetime         not null
#  private_key :string(1024)     not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TimeBasedOneTimePassword < UniversalRecord
  attr_accessor :first_token

  # Encrypts the column value
  encrypts :private_key, downcase: true

  validates :first_token, presence: true, length: { is: 6 },
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
