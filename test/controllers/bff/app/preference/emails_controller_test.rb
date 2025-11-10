# frozen_string_literal: true

require "test_helper"
require "uri"

class Bff::App::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "GET new renders the request form" do
    get new_bff_app_preference_email_url

    assert_response :success
    assert_select "form"
    assert_select "input[name='email_preference_request[email_address]']", count: 1
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "POST create with valid email enqueues a mail and redirects" do
    assert_difference "EmailPreferenceRequest.count", 1 do
      post bff_app_preference_emails_url, params: { email_preference_request: { email_address: "user@example.com" } }
    end

    assert_response :redirect
    assert_match %r{/preference}, response.location
    email = ActionMailer::Base.deliveries.last

    assert_equal [ "user@example.com" ], email.to
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "POST create with invalid email re-renders the form" do
    post bff_app_preference_emails_url, params: { email_preference_request: { email_address: "invalid" } }

    assert_response :unprocessable_entity
    assert_select "div.bg-red-50"
    assert_empty ActionMailer::Base.deliveries
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "GET edit with valid token shows the pref form" do
    email_request = create_app_request

    get edit_bff_app_preference_email_url(id: email_request.raw_token)

    assert_response :success
    assert_select "form"
    assert_select "input[type='checkbox'][name='email_preference_request[product_updates]']", count: 1
    assert_select "input[type='checkbox'][name='email_preference_request[promotional_messages]']", count: 1
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "GET edit with invalid token redirects to the request page" do
    get edit_bff_app_preference_email_url(id: "missing-token")

    assert_response :redirect
    assert_equal "/preference/emails/new", URI(response.location).path
    assert_equal I18n.t("bff.shared.preference_emails.token_invalid"), flash[:alert]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "PATCH update saves preferences and marks the token used" do
    email_request = create_app_request

    patch bff_app_preference_email_url(id: email_request.raw_token), params: { email_preference_request: { product_updates: "0", promotional_messages: "1" } }

    assert_response :redirect
    assert_equal "/preference", URI(response.location).path

    email_request.reload

    assert_in_delta Time.current, email_request.token_used_at, 1.second
    assert_not email_request.preferences["product_updates"]
    assert email_request.preferences["promotional_messages"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "PATCH update with a spent token redirects to the request page" do
    email_request = create_app_request
    email_request.update!(token_used_at: 1.hour.ago)

    patch bff_app_preference_email_url(id: email_request.raw_token), params: { email_preference_request: { product_updates: "1" } }

    assert_response :redirect
    assert_equal "/preference/emails/new", URI(response.location).path
    assert_equal I18n.t("bff.shared.preference_emails.token_invalid"), flash[:alert]
  end

  private

  def create_app_request
    request = EmailPreferenceRequest.new(email_address: "user@example.com", context: :app)
    request.save!
    request
  end
end
