# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_token_statuses, :staff_token_kinds

  setup do
    host! ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
    @host = ENV["SIGN_STAFF_URL"] || "sign.org.localhost"
    # Create a token for the current session
    @current_token = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )
    @headers = {
      "Host" => @host,
      "X-TEST-CURRENT-STAFF" => @staff.id.to_s,
      "X-TEST-SESSION-PUBLIC-ID" => @current_token.public_id,
      "User-Agent" => AuthHelpers::MODERN_USER_AGENT,
    }.freeze
    @unauthenticated_headers = {
      "Host" => @host,
      "User-Agent" => AuthHelpers::MODERN_USER_AGENT,
    }.freeze
  end

  # ===================================================================
  # index
  # ===================================================================

  test "index returns active sessions as JSON" do
    get sign_org_configuration_sessions_url(ri: "jp", format: :json),
        headers: @headers.merge("Accept" => "application/json")

    assert_response :success
    body = response.parsed_body

    assert body.key?("sessions")
    assert body["sessions"].any? { |s| s["public_id"] == @current_token.public_id }
  end

  test "index excludes expired sessions from JSON response" do
    expired_token = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )
    expired_token.revoke!

    get sign_org_configuration_sessions_url(ri: "jp", format: :json),
        headers: @headers.merge("Accept" => "application/json")

    assert_response :success
    body = response.parsed_body
    public_ids = body["sessions"].pluck("public_id")

    assert_not_includes public_ids, expired_token.public_id
  end

  test "index returns HTML by default" do
    get sign_org_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "index requires authentication" do
    get sign_org_configuration_sessions_url(ri: "jp"), headers: @unauthenticated_headers

    assert_response :redirect
  end

  # ===================================================================
  # destroy
  # ===================================================================

  test "destroy revokes other session and redirects with see_other" do
    other_token = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )

    delete sign_org_configuration_session_url(other_token.public_id, ri: "jp"), headers: @headers

    assert_response :see_other
    other_token.reload

    assert_not_nil other_token.expired_at
  end

  test "destroy current session returns error redirect instead of revoking" do
    delete sign_org_configuration_session_url(@current_token.public_id, ri: "jp"), headers: @headers

    assert_response :redirect
    assert_match(/configuration\/sessions/, response.location)

    # Current session must remain alive
    @current_token.reload

    assert_nil @current_token.expired_at
  end

  test "destroy non-existent session returns 404" do
    delete sign_org_configuration_session_url("nonexistent_public_id", ri: "jp"), headers: @headers

    assert_response :not_found
  end

  test "destroy requires authentication" do
    other_token = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )

    delete sign_org_configuration_session_url(other_token.public_id, ri: "jp"),
           headers: @unauthenticated_headers

    assert_response :redirect
    other_token.reload

    assert_nil other_token.expired_at
  end

  test "destroy does not revoke session belonging to another staff" do
    other_staff = staffs(:two)
    other_staff_token = StaffToken.create!(
      staff_id: other_staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )

    # Try to destroy another staff's token using current staff's session
    delete sign_org_configuration_session_url(other_staff_token.public_id, ri: "jp"),
           headers: @headers

    # set_session scopes to current_staff so it won't find it -- 404
    assert_response :not_found
    other_staff_token.reload

    assert_nil other_staff_token.expired_at
  end

  # ===================================================================
  # others
  # ===================================================================

  test "others revokes all sessions except current" do
    other_token = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )

    delete others_sign_org_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :see_other

    @current_token.reload
    other_token.reload

    assert_nil @current_token.expired_at
    assert_not_nil other_token.expired_at
  end

  test "others with no other sessions still succeeds (boundary: 0 other sessions)" do
    # Only the current session exists
    delete others_sign_org_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :see_other
    @current_token.reload

    assert_nil @current_token.expired_at
  end

  test "others requires authentication" do
    delete others_sign_org_configuration_sessions_url(ri: "jp"), headers: @unauthenticated_headers

    assert_response :redirect
  end

  test "others does not revoke already-expired sessions" do
    already_expired = StaffToken.create!(
      staff_id: @staff.id,
      staff_token_kind_id: StaffTokenKind::BROWSER_WEB,
      refresh_expires_at: 1.day.from_now,
    )
    already_expired.revoke!
    original_expired_at = already_expired.reload.expired_at

    delete others_sign_org_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :see_other
    already_expired.reload
    # expired_at should not change (already filtered out by where(expired_at: nil))
    assert_equal original_expired_at.to_i, already_expired.expired_at.to_i
  end
end
