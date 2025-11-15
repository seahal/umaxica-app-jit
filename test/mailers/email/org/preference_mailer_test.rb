# frozen_string_literal: true

require "test_helper"

module Email::Org
  class PreferenceMailerTest < ActionMailer::TestCase
    # TODO: Uncomment when EmailPreferenceRequest model is available
    # setup do
    #   @preference_request = EmailPreferenceRequest.new(
    #     email_address: "test@example.com",
    #     context: "org"
    #   )
    #   @edit_url = "https://example.com/preferences/edit?token=test_token"
    # end
    #
    # test "update_request should send email" do
    #   email = PreferenceMailer.with(
    #     preference_request: @preference_request,
    #     edit_url: @edit_url
    #   ).update_request
    #
    #   assert_emails 1 do
    #     email.deliver_now
    #   end
    # end
    #
    # test "update_request should have correct recipient" do
    #   email = PreferenceMailer.with(
    #     preference_request: @preference_request,
    #     edit_url: @edit_url
    #   ).update_request
    #
    #   assert_equal ["test@example.com"], email.to
    # end
    #
    # test "update_request should have subject" do
    #   email = PreferenceMailer.with(
    #     preference_request: @preference_request,
    #     edit_url: @edit_url
    #   ).update_request
    #
    #   assert_not_nil email.subject
    # end
  end
end
