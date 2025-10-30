require "test_helper"


class Email::Com::ApplicationMailerTest < ActionMailer::TestCase
  # rubocop:disable Minitest/MultipleAssertions
  test "applies default from address" do
    expected_from = Rails.application.credentials.dig(:SMTP_FROM_ADDRESS)

    assert_equal expected_from, Email::Com::ApplicationMailer.default[:from]

    mailer = Class.new(Email::Com::ApplicationMailer) do
      def sample
        mail(to: "com-user@example.com", subject: I18n.t("test.email.com.application_mailer.subject")) do |format|
          format.text { render plain: "hello" }
        end
      end
    end

    I18n.backend.store_translations(:en, { test: { email: { com: { application_mailer: { subject: "Com Sample" } } } } })
    email = mailer.new.sample

    assert_equal [ expected_from ], email.from
    assert_equal [ "com-user@example.com" ], email.to
    assert_equal I18n.t("test.email.com.application_mailer.subject"), email.subject
    assert_equal "hello", email.body.encoded
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "uses corporate mailer layout" do
    assert_equal "mailer/com/mailer", Email::Com::ApplicationMailer._layout
  end
end
