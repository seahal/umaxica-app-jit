# == Schema Information
#
# Table name: service_site_contacts
#
#  id               :uuid             not null, primary key
#  description      :text
#  email_address    :string
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
        telephone_number: "+81901232456789",
        email_pass_code: 123456,
        telephone_pass_code: 123456,
        title: "good title",
        description: "good description")
    end

    test "good #{model}'s email pattern" do
        #    assert_changes(model.count) do
        assert @good_pattern.valid?
        assert @good_pattern.save
        @good_pattern.email_address = "x@example.net"
        assert @good_pattern.valid?
      # endrequire "test_helper"
    end

    test "valid #{model}'s email otp password pattern" do
      assert model.new(email_pass_code: nil, telephone_pass_code: 123456).valid?
      assert model.new(email_pass_code: 123456, telephone_pass_code: nil).valid?
      # refute model.new(email_pass_code: 123456, telephone_pass_code: 123456).valid?
    end

    test "good #{model}'s email otp password pattern" do
      assert model.new(email_pass_code: 123456).valid?
      refute model.new(email_pass_code: 12345).valid?
      refute model.new(email_pass_code: 1234567).valid?
      refute model.new(email_pass_code: 0).valid?
      refute model.new(email_pass_code: 1).valid?
    end

    test "good #{model}'s telephone otp password pattern" do
      assert model.new(telephone_pass_code: 123456).valid?
      refute model.new(telephone_pass_code: 12345).valid?
      refute model.new(telephone_pass_code: 1234567).valid?
      refute model.new(telephone_pass_code: 0).valid?
      refute model.new(telephone_pass_code: 1).valid?
    end
    #
    # test "good #{model}'s confirm pattern" do
    #   assert_no_changes(model.count) do
    #     assert_not model.new(confirm_policy: false, email_address: "eg@example.com", telephone_number: "+81901232456789").valid?
    #   end
    # end
    #
    # test "valid #{model}'s email pattern" do
    #   eg = model.count
    #   model.create(email_address: "eg@example.net", telephone_number: "+8180123245689")
    #   assert_equal eg + 1, model.count
    # end
    #
    # test "bad #{model}'s email pattern" do
    #   valid_telephone_number = "+81701232456789"
    #   assert_not model.new(email_address: "", telephone_number: valid_telephone_number).valid?
    # end
  end
end
