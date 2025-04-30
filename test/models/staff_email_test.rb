# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  test "good 's email pattern" do
    assert StaffEmail.create(address: "eg@example.com").valid?
  end

  test "StaffEmail can't be blank" do
    assert_not StaffEmail.new(address: "").valid?
  end

  test "StaffEmail should be case insensitive unique" do
    eg = StaffEmail.create(address: "eg@example.com")
    assert_not StaffEmail.new(address: eg.address).valid?
    assert_not StaffEmail.new(address: eg.address.upcase).valid?
  end

  test "StaffEmail address should be shorter <= 255" do
    StaffEmail.create(address: "a@b.c")
    assert_no_difference "StaffEmail.count" do
      assert_not StaffEmail.create(address: "a@b.c").valid?
    end
  end

  test "validable StaffEmail addresses" do
    assert StaffEmail.new(address: "Abc@example.com").valid?
    assert StaffEmail.new(address: "Abc.123@example.com").valid?
    # assert StaffEmail.new(address: 'user+mailbox/department=shipping@example.com').valid?
    # assert StaffEmail.new(address: "!#$%&'*+-/=?^_`.{|}~@example.com").valid?
    # assert StaffEmail.new(address: '"Abc@def"@example.com').valid?
    # assert StaffEmail.new(address: "\"Fred\ Bloggs\"@example.com").valid?
    # assert StaffEmail.new(address: '"Joe.\\Blow"@example.com').valid?
  end

  test "StaffEmail should be only one" do
    StaffEmail.create(address: "a@b.c")
    assert_no_difference "StaffEmail.count" do
      assert_not StaffEmail.create(address: "a@b.c").valid?
    end
  end

  test "StaffEmail : a@b.c is equal to A@b.c, A@B.C A@B.c, ... A@B.C" do
    assert StaffEmail.create(address: "a@b.c").valid?
    [ "A@b.c", "A@B.c", "A@B.C", "a@B.c", "a@B.C", "a@b.C" ].each do |_address|
      assert_no_difference "StaffEmail.count", 1 do
        assert_not StaffEmail.create(address: "A@B.C").valid?
      end
    end
  end
end
