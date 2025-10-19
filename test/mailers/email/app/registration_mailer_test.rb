require "test_helper"

class Email::App::RegistrationMailerTest < ActionMailer::TestCase
  test "create" do
    mail = Email::App::RegistrationMailer.with(hotp_token: "123456", email_address: "user@example.com").create

    assert_equal "Create", mail.subject
    assert_equal [ "user@example.com" ], mail.to
    assert_equal [ "from@umaxica.net" ], mail.from
    assert_match "123456", mail.body.encoded
  end
end
