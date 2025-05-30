# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id             :binary           default(""), not null, primary key
#  address        :string(1024)     not null
#  emailable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :binary           not null
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  [ StaffEmail, UserEmail, ClientEmail ].each do |model|
    test "good #{model}'s email pattern" do
      assert model.create(address: "eg@example.com").valid?
    end

    test "Email(#{model}) can't be blank" do
      assert_not model.new(address: "").valid?
    end

    test "Email(#{model}) should be case insensitive unique" do
      eg = model.create(address: "eg@example.com")
      assert_not model.new(address: eg.address).valid?
      assert_not model.new(address: eg.address.upcase).valid?
    end

    test "email(#{model}) address should be shorter <= 255" do
      UserEmail.create(address: "a@b.c")
      assert_no_difference "UserEmail.count" do
        assert_not UserEmail.create(address: "a@b.c").valid?
      end
    end

    test "validable email(#{model}) addresses" do
      assert model.new(address: "Abc@example.com").valid?
      assert model.new(address: "Abc.123@example.com").valid?
      assert model.new(address: "user+mailbox/department=shipping@example.com").valid?
      assert model.new(address: "!#$%&'*+-/=?^_`.{|}~@example.com").valid?
    end

    test "email(#{model}) should be only one" do
      model.create(address: "a@b.c")
      assert_no_difference "UserEmail.count" do
        assert_not model.create(address: "a@b.c").valid?
      end
    end

    test "email(#{model}) : a@b.c is equal to A@b.c, A@B.C A@B.c, ... A@B.C" do
      assert model.create(address: "a@b.c").valid?
      [ "A@b.c", "A@B.c", "A@B.C", "a@B.c", "a@B.C", "a@b.C" ].each do |_address|
        assert_no_difference "UserEmail.count", 1 do
          assert_not model.create(address: "A@B.C").valid?
        end
      end
    end

    test "email(#{model}) : email address must downcase." do
      mail_address = "A@B.C".upcase
      model.create(address: mail_address)
      assert_not_equal model.first.address, mail_address
      assert_equal model.first.address, mail_address.downcase
      assert_equal model.first.address.upcase, mail_address
    end

    test "email(#{model}) : email address was downcase." do
      m = model.new(address: nil)
      m.pass_code = 123456
      assert m.valid?
      m.pass_code = 12345
      refute m.valid?
      m.pass_code = 1234567
      refute m.valid?
      m.pass_code = 0
      refute m.valid?
      m.pass_code = nil
      refute m.valid?
    end

    test "email(#{model}) : Address and pass_code cannot both be nil." do
      m = model.new(address: nil, pass_code: nil)
      refute m.valid?
    end
  end
end
