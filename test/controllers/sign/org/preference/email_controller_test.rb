# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Preference::EmailControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_ORGANIZATION_URL", "sign.org.localhost")
  end

  test "should get index" do
    get sign_org_preference_email_index_url(ri: "jp")

    assert_response :success
  end

  test "should get show" do
    get sign_org_preference_email_url(id: "primary", ri: "jp")

    assert_response :redirect
  end

  test "should create email" do
    post sign_org_preference_email_index_url(ri: "jp"), params: { preference_email: { email: "new@example.com" } }

    assert_redirected_to sign_org_preference_email_url(id: "primary")
  end

  test "should get edit" do
    get edit_sign_org_preference_email_url(id: "primary", ri: "jp")

    assert_response :success
  end

  test "should update email" do
    patch sign_org_preference_email_url(id: "primary", ri: "jp"),
          params: { preference_email: { email: "updated@example.com" } }

    assert_response :redirect
  end
end
