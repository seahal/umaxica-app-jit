require "ostruct"
require "test_helper"

class Email::Com::TopicMailerTest < ActionMailer::TestCase
  test "notice includes topic details" do
    contact = OpenStruct.new(public_id: "test-contact-123")
    topic = OpenStruct.new(title: "Inq title", description: "Detail of inquiry.")
    recipient = "recipient@example.com"

    mail = Email::Com::TopicMailer.with(
      contact: contact,
      topic: topic,
      email_address: recipient
    ).notice

    assert_equal "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - We received your inquiry", mail.subject
    assert_equal [recipient], mail.to
    assert_match "Inq title", mail.body.encoded
    assert_match "Detail of inquiry.", mail.body.encoded
  end
end
