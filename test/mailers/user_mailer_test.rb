# delable
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    mail = UserMailer.welcome_email
    assert_equal "Welcome email", mail.subject
    assert_equal [], mail.to
    assert_equal [], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
