require "test_helper"

class Email::App::RegistrationMailerTest < ActionMailer::TestCase
  test "create" do
    mail = Email::App::RegistrationMailer.with(hotp_token: "123456", email_address: "user@example.com").create

    assert_equal "Create", mail.subject
    assert_equal [ "user@example.com" ], mail.to
    assert_equal [ "from@umaxica.net" ], mail.from
    assert_match "123456", mail.body.encoded
  end

  test "create with different hotp_token" do
    mail = Email::App::RegistrationMailer.with(hotp_token: "654321", email_address: "test@example.com").create

    assert_match "654321", mail.body.encoded
    assert_equal [ "test@example.com" ], mail.to
  end

  test "should set greeting instance variable from hotp_token" do
    mail = Email::App::RegistrationMailer.with(hotp_token: "999888", email_address: "greet@example.com").create

    assert_match "999888", mail.body.encoded
  end

  test "mail should have correct from address" do
    mail = Email::App::RegistrationMailer.with(hotp_token: "111111", email_address: "test@example.com").create

    assert_equal [ "from@umaxica.net" ], mail.from
  end
end
