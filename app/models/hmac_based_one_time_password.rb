# == Schema Information
#
# Table name: hmac_based_one_time_passwords
#
#  id          :uuid             not null, primary key
#  last_otp_at :datetime         not null
#  private_key :string(1024)     not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class HmacBasedOneTimePassword < UniversalRecord
end
