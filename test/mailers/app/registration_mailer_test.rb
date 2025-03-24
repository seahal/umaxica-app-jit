require "test_helper"

class App::RegistrationMailerTest < ActionMailer::TestCase
  test "two" do
    mail = App::RegistrationMailer.two
    assert_equal "Two", mail.subject
    # assert_equal [ "to@example.org" ], mail.to
    # assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
