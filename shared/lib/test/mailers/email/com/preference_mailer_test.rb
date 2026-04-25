# typed: false
# frozen_string_literal: true

require "test_helper"

class Email::Com::PreferenceMailerTest < ActionMailer::TestCase
  test "update_request includes preference request details" do
    preference_request = OpenStruct.new(address: "user@example.com")
    edit_url = "https://example.com/preferences/edit"

    mail = Email::Com::PreferenceMailer.with(
      preference_request: preference_request,
      edit_url: edit_url,
    ).update_request

    assert_equal [preference_request.address], mail.to
    assert_match(/preferences?/i, mail.subject)
    body_text = mail.text_part&.decoded || mail.body.decoded

    assert_match edit_url, body_text
  end

  test "update_request sets correct from address" do
    preference_request = OpenStruct.new(address: "user@example.com")

    mail = Email::Com::PreferenceMailer.with(
      preference_request: preference_request,
      edit_url: "https://example.com/edit",
    ).update_request

    assert_equal [Rails.app.creds.require(:SMTP_FROM_ADDRESS)], mail.from
  end
end
