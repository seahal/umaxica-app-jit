require "test_helper"

class TimeBasedOneTimePasswordTest < ActiveSupport::TestCase
  test "validation of prvate_key" do
    tbotp = TimeBasedOneTimePassword.new(id: "00000000-0000-0000-0000-0000000000110")
    refute tbotp.valid?
    tbotp.private_key = "EXAMPLE"
    tbotp.first_token = 123456
    tbotp.second_token = 123456
    assert tbotp.valid?
    tbotp.private_key = ""
    refute tbotp.valid?
    tbotp.private_key = nil
    refute tbotp.valid?
    tbotp.private_key = "EXAMPLE2"
    assert tbotp.save
  end

  test "validations of first_token" do
    tbotp = TimeBasedOneTimePassword.new(private_key: "SAMPLE")
    refute tbotp.valid?
    tbotp.first_token = 123456
    tbotp.second_token = 123456
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

  test "validation of second_token" do
    tbotp = TimeBasedOneTimePassword.new(private_key: "SAMPLE")
    refute tbotp.valid?
    tbotp.first_token = 123456
    tbotp.second_token = 123456
    assert tbotp.valid?
    tbotp.second_token = 12345
    refute tbotp.valid?
    tbotp.second_token = 1234567
    refute tbotp.valid?
    tbotp.second_token = nil
    refute tbotp.valid?
    tbotp.second_token = ""
    refute tbotp.valid?
    tbotp.second_token = "abcdef"
    refute tbotp.valid?
    tbotp.second_token = 123456
    assert tbotp.valid?
  end

  test "check the field encryption" do
    tbotp = TimeBasedOneTimePassword.create(private_key: "EXAMPLE", first_token: 123456, second_token: 123456, id: "00000000-0000-0000-0000-0000000000100")
    assert tbotp.encrypted_attribute? :private_key
    refute tbotp.encrypted_attribute? :id
  end
end
