# == Schema Information
#
# Table name: service_site_contacts
#
#  id               :uuid             not null, primary key
#  description      :text
#  email_address    :string
#  ip_address       :cidr
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class ServiceSiteContactTest < ActiveSupport::TestCase
  [ ServiceSiteContact ].each do |model|
    setup do
      @good_pattern = model.new(
        confirm_policy: true,
        email_address: "eg@example.com",
        telephone_number: "+819012345678",
        email_pass_code: 123456,
        telephone_pass_code: 123456,
        title: "good title",
        description: "good description")
    end

    test "good #{model}'s email pattern" do
      assert @good_pattern.valid?
      assert @good_pattern.save
      @good_pattern.email_address = "x@example.net"
      assert @good_pattern.valid?
    end

    test "valid #{model}'s confirmation check" do
      assert @good_pattern.valid?
      @good_pattern.confirm_policy = false
      refute @good_pattern.valid?
      @good_pattern.confirm_policy = nil
      assert @good_pattern.valid?
    end

    test "invalid #{model}'s email patterns" do
      [ nil, "", "example..com", "exampleexample.com", "xample@#example.jp", "@example.com" ].each do
        @good_pattern.email_address = it
        refute @good_pattern.valid?
      end
    end

    test "valid #{model}'s email patterns" do
      [ "example@example.org" ].each do |chars|
        @good_pattern.email_address = chars
        assert @good_pattern.valid?
      end
    end

    test "invalid #{model}'s telephone number patterns" do
      [ "", nil, "+810901234", "81901234" ].each do
        @good_pattern.email_address = it
        refute @good_pattern.valid?
      end
    end

    test "valid #{model}'s telephone number patterns" do
      [ "+811" ].each do
        @good_pattern.email_address = it
        refute @good_pattern.valid?
      end
    end

    test "good #{model}'s email otp password pattern" do
      assert model.new(email_pass_code: 123456).valid?
      assert model.new(email_pass_code: nil).valid?
      refute model.new(email_pass_code: 12345).valid?
      refute model.new(email_pass_code: 1234567).valid?
      refute model.new(email_pass_code: 0).valid?
      refute model.new(email_pass_code: 1).valid?
      assert model.new(email_pass_code: nil, telephone_pass_code: 123456).valid?
    end

    test "good #{model}'s telephone otp password pattern" do
      assert model.new(telephone_pass_code: 123456).valid?
      assert model.new(telephone_pass_code: nil).valid?
      refute model.new(telephone_pass_code: 12345).valid?
      refute model.new(telephone_pass_code: 1234567).valid?
      refute model.new(telephone_pass_code: 0).valid?
      refute model.new(telephone_pass_code: 1).valid?
      assert model.new(email_pass_code: 123456, telephone_pass_code: nil).valid?
    end

    test "bad #{model}'s title pattern" do
      [ "", "a" * 7, "a" * 256 ].each do
        @good_pattern.title = it
        refute @good_pattern.valid?
      end
    end

    test "good #{model}'s title pattern" do
      [ "a" * 8, "a" * 255, nil ].each do
        @good_pattern.title = it
        assert @good_pattern.valid?
      end
    end

    test "bad #{model}'s description pattern" do
      [ "", "a" * 7, "a" * 1024 ].each do
        @good_pattern.description = it
        refute @good_pattern.valid?
      end
    end

    test "good #{model}'s description pattern" do
      [ "a" * 8, "a" * 1023, nil ].each do
        @good_pattern.description = it
        assert @good_pattern.valid?
      end
    end

    test "none is invalid of #{model}'s pattern" do
      assert_raise do
        ServiceSiteContact.create
      end
    end

    # test "bad #{model}'s email pattern" do
    #   valid_telephone_number = "+81701232456789"
    #   assert_not model.new(email_address: "", telephone_number: valid_telephone_number).valid?
    # end
  end
end
