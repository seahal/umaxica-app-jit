# typed: false
# frozen_string_literal: true

require "test_helper"

module Email::Org
  class ContactMailerTest < ActionMailer::TestCase
    test "create with email_address parameter" do
      mail = ContactMailer.with(email_address: "org-test@example.com", pass_code: "123456").create

      assert_equal "#{ENV.fetch("BRAND_NAME", "Umaxica")} - Email Verification Code", mail.subject
      assert_equal ["org-test@example.com"], mail.to
    end

    test "create with pass_code parameter" do
      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "654321").create

      assert_match "654321", mail.body.encoded
    end

    test "should set pass_code instance variable" do
      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "111111").create

      assert_match "111111", mail.body.encoded
    end

    test "should include verification code in html body" do
      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "999888").create

      assert_match "999888", mail.html_part.body.decoded
    end

    test "should include verification code in text body" do
      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "777666").create

      assert_match "777666", mail.text_part.body.decoded
    end

    test "should have both html and text parts" do
      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "555444").create

      assert_predicate mail, :multipart?
      assert_not_nil mail.html_part
      assert_not_nil mail.text_part
    end

    test "should use correct brand name in subject" do
      original_brand = ENV["BRAND_NAME"]
      ENV["BRAND_NAME"] = "OrgTestBrand"

      mail = ContactMailer.with(email_address: "org-user@example.com", pass_code: "123456").create

      assert_equal "OrgTestBrand - Email Verification Code", mail.subject
    ensure
      ENV["BRAND_NAME"] = original_brand
    end

    test "ContactMailer inherits from ApplicationMailer" do
      assert_kind_of Class, ContactMailer
      assert_operator ContactMailer, :<, ApplicationMailer
    end

    test "ContactMailer responds to create" do
      assert_respond_to ContactMailer, :create
    end
  end
end
