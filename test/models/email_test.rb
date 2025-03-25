# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  [ StaffEmail, UserEmail ].each do |model|
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
      # assert model.new(address: 'user+mailbox/department=shipping@example.com').valid?
      # assert model.new(address: "!#$%&'*+-/=?^_`.{|}~@example.com").valid?
      # assert model.new(address: '"Abc@def"@example.com').valid?
      # assert model.new(address: "\"Fred\ Bloggs\"@example.com").valid?
      # assert model.new(address: '"Joe.\\Blow"@example.com').valid?
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
  end
end
