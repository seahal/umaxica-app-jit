require "test_helper"

class Email::App::ContactMailerTest < ActionMailer::TestCase
  test "create" do
    mail = Email::App::ContactMailer.create
    assert_equal "Create", mail.subject
    # assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@umaxica.net" ], mail.from
    assert_match "pass", mail.body.encoded
  end
end
