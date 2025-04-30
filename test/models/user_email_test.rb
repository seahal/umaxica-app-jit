# == Schema Information
#
# Table name: user_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class UserEmailTest < ActiveSupport::TestCase
  test "good 's email pattern" do
    assert UserEmail.create(address: "eg@example.com").valid?
  end

  test "UserEmail can't be blank" do
    assert_not UserEmail.new(address: "").valid?
  end

  test "UserEmail should be case insensitive unique" do
    eg = UserEmail.create(address: "eg@example.com")
    assert_not UserEmail.new(address: eg.address).valid?
    assert_not UserEmail.new(address: eg.address.upcase).valid?
  end

  test "UserEmail address should be shorter <= 255" do
    UserEmail.create(address: "a@b.c")
    assert_no_difference "UserEmail.count" do
      assert_not UserEmail.create(address: "a@b.c").valid?
    end
  end

  test "validable UserEmail addresses" do
    assert UserEmail.new(address: "Abc@example.com").valid?
    assert UserEmail.new(address: "Abc.123@example.com").valid?
    # assert UserEmail.new(address: 'user+mailbox/department=shipping@example.com').valid?
    # assert UserEmail.new(address: "!#$%&'*+-/=?^_`.{|}~@example.com").valid?
    # assert UserEmail.new(address: '"Abc@def"@example.com').valid?
    # assert UserEmail.new(address: "\"Fred\ Bloggs\"@example.com").valid?
    # assert UserEmail.new(address: '"Joe.\\Blow"@example.com').valid?
  end

  test "UserEmail should be only one" do
    UserEmail.create(address: "a@b.c")
    assert_no_difference "UserEmail.count" do
      assert_not UserEmail.create(address: "a@b.c").valid?
    end
  end

  test "UserEmail : a@b.c is equal to A@b.c, A@B.C A@B.c, ... A@B.C" do
    assert UserEmail.create(address: "a@b.c").valid?
    [ "A@b.c", "A@B.c", "A@B.C", "a@B.c", "a@B.C", "a@b.C" ].each do |_address|
      assert_no_difference "UserEmail.count", 1 do
        assert_not UserEmail.create(address: "A@B.C").valid?
      end
    end
  end
end
