# frozen_string_literal: true

require "test_helper"
require "uri"

class Bff::Org::Preference::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "GET new renders the request form" do
    get new_bff_org_preference_email_url

    assert_response :success
    assert_select "input[name='email_preference_request[email_address]']"
  end

  test "POST create with valid email sends mail" do
    assert_difference "EmailPreferenceRequest.count", 1 do
      post bff_org_preference_emails_url, params: { email_preference_request: { email_address: "staff@example.com" } }
    end

    assert_response :redirect
    email = ActionMailer::Base.deliveries.last
    assert_equal [ "staff@example.com" ], email.to
  end

  test "POST create with invalid email renders errors" do
    post bff_org_preference_emails_url, params: { email_preference_request: { email_address: "invalid" } }

    assert_response :unprocessable_entity
    assert_select "div.bg-red-50"
  end

  test "GET edit with valid token renders checkboxes" do
    email_request = create_org_request

    get edit_bff_org_preference_email_url(id: email_request.raw_token)

    assert_response :success
    assert_select "input[type='checkbox'][name='email_preference_request[product_updates]']", count: 1
    assert_select "input[type='checkbox'][name='email_preference_request[promotional_messages]']", count: 1
  end

  test "GET edit with invalid token redirects" do
    get edit_bff_org_preference_email_url(id: "invalid")

    assert_response :redirect
    assert_equal "/preference/emails/new", URI(response.location).path
    assert_equal I18n.t("bff.shared.preference_emails.token_invalid"), flash[:alert]
  end

  test "PATCH update stores preferences and marks token used" do
    email_request = create_org_request

    patch bff_org_preference_email_url(id: email_request.raw_token), params: { email_preference_request: { product_updates: "0" } }

    assert_response :redirect
    assert_equal "/preference", URI(response.location).path
    email_request.reload
    assert_equal false, email_request.preferences["product_updates"]
    assert_in_delta Time.current, email_request.token_used_at, 1.second
  end

  test "PATCH update with used token redirects to request path" do
    email_request = create_org_request
    email_request.update!(token_used_at: 2.hours.ago)

    patch bff_org_preference_email_url(id: email_request.raw_token), params: { email_preference_request: { promotional_messages: "0" } }

    assert_response :redirect
    assert_equal "/preference/emails/new", URI(response.location).path
    assert_equal I18n.t("bff.shared.preference_emails.token_invalid"), flash[:alert]
  end

  private

  def create_org_request
    request = EmailPreferenceRequest.new(email_address: "staff@example.com", context: :org)
    request.save!
    request
  end
end
