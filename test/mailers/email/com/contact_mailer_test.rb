require "test_helper"

class Email::Com::ContactMailerTest < ActionMailer::TestCase
  test "create with email_address parameter" do
    mail = Email::Com::ContactMailer.with(email_address: "test@example.com", pass_code: "123456").create

    assert_equal "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - Email Verification Code", mail.subject
    assert_equal [ "test@example.com" ], mail.to
    assert_equal [ "from@umaxica.net" ], mail.from
  end

  test "create with pass_code parameter" do
    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "654321").create

    assert_match "654321", mail.body.encoded
  end

  test "should set pass_code instance variable" do
    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "111111").create

    assert_match "111111", mail.body.encoded
  end

  test "should include verification code in html body" do
    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "999888").create

    assert_match "999888", mail.html_part.body.decoded
  end

  test "should include verification code in text body" do
    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "777666").create

    assert_match "777666", mail.text_part.body.decoded
  end

  test "should have both html and text parts" do
    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "555444").create

    assert mail.multipart?
    assert_not_nil mail.html_part
    assert_not_nil mail.text_part
  end

  test "should use correct brand name in subject" do
    original_brand = ENV['BRAND_NAME']
    ENV['BRAND_NAME'] = 'TestBrand'

    mail = Email::Com::ContactMailer.with(email_address: "user@example.com", pass_code: "123456").create

    assert_equal "TestBrand - Email Verification Code", mail.subject
  ensure
    ENV['BRAND_NAME'] = original_brand
  end
end
