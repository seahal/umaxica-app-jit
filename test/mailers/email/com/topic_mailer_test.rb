require "ostruct"
require "test_helper"

class Email::Com::TopicMailerTest < ActionMailer::TestCase
  test "notice includes topic details" do
    contact = OpenStruct.new(public_id: "test-contact-123")
    topic = OpenStruct.new(title: "Inq title", description: I18n.t("test_data.inquiry_detail"))
    recipient = "recipient@example.com"

    mail = Email::Com::TopicMailer.with(
      contact: contact,
      topic: topic,
      email_address: recipient
    ).notice

    assert_equal [
      "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - We received your inquiry",
      [ recipient ]
    ], [ mail.subject, mail.to ]
    body_text = mail.text_part&.decoded || mail.body.decoded

    assert_match "Inq title", body_text
    assert_match I18n.t("test_data.inquiry_detail"), body_text
  end
end
