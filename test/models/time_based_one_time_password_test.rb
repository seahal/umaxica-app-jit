# == Schema Information
#
# Table name: time_based_one_time_passwords
#
#  id          :binary           not null, primary key
#  last_otp_at :datetime         not null
#  private_key :string(1024)     not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class TimeBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "validation of prvate_key" do
    tbotp = TimeBasedOneTimePassword.new(id: "00000000-0000-0000-0000-0000000000110")
    refute tbotp.valid?
    tbotp.private_key = "EXAMPLE"
    tbotp.first_token = 123456
    assert tbotp.valid?
    tbotp.private_key = ""
    assert tbotp.valid?
    tbotp.private_key = nil
    assert tbotp.valid?
    tbotp.private_key = "EXAMPLE2"
    assert tbotp.save
  end

  test "validations of first_token" do
    tbotp = TimeBasedOneTimePassword.new(private_key: "SAMPLE")
    refute tbotp.valid?
    tbotp.first_token = 123456
    assert tbotp.valid?
    tbotp.first_token = 12345
    refute tbotp.valid?
    tbotp.first_token = 1234567
    refute tbotp.valid?
    tbotp.first_token = nil
    refute tbotp.valid?
    tbotp.first_token = ""
    refute tbotp.valid?
    tbotp.first_token = "abcdef"
    refute tbotp.valid?
    tbotp.first_token = 123456
    assert tbotp.valid?
  end

  test "check the field encryption" do
    tbotp = TimeBasedOneTimePassword.create(private_key: "EXAMPLE", first_token: 123456, id: "00000000-0000-0000-0000-0000000000100")
    assert tbotp.encrypted_attribute? :private_key
    refute tbotp.encrypted_attribute? :id
  end
end
