require "test_helper"

class Email::Com::ApplicationMailerTest < ActionMailer::TestCase
  test "applies default from address" do
    expected_from = Rails.application.credentials.dig(:SMTP_FROM_ADDRESS)
    assert_equal expected_from, Email::Com::ApplicationMailer.default[:from]

    mailer = Class.new(Email::Com::ApplicationMailer) do
      def sample
        mail(to: "com-user@example.com", subject: "Com Sample") do |format|
          format.text { render plain: "hello" }
        end
      end
    end

    email = mailer.new.sample

    assert_equal [expected_from], email.from
    assert_equal ["com-user@example.com"], email.to
    assert_equal "Com Sample", email.subject
    assert_equal "hello", email.body.encoded
  end

  test "uses corporate mailer layout" do
    assert_equal "mailer/com/mailer", Email::Com::ApplicationMailer._layout
  end
end
