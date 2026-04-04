# typed: false
# frozen_string_literal: true

require "test_helper"

# Test to verify behavior when preference_refresh cookie is deleted/lost
class PreferenceRefreshLostTest < ActionDispatch::IntegrationTest
  fixtures :app_preference_statuses

  setup do
    @host = "main.app.localhost"
    host! @host
  end

  test "when preference_refresh is lost, new preference is created on next request" do
    # Step 1: Create initial session with preference
    s = open_session
    s.host!(@host)

    s.get(main_app_edge_v0_preference_url)
    s.assert_response :success

    original_public_id = s.response.parsed_body.dig("preference", "public_id")
    original_refresh = s.cookies[preference_refresh_cookie_name]
    original_access = s.cookies[preference_access_cookie_name]

    assert_predicate original_public_id, :present?, "Should have initial preference"
    assert_predicate original_refresh, :present?, "Should have refresh cookie"
    assert_predicate original_access, :present?, "Should have access cookie"

    # Step 2: Simulate refresh cookie being lost (deleted by user/browser)
    s.cookies.delete(preference_refresh_cookie_name)
    s.cookies.delete(preference_access_cookie_name)
    s.cookies.delete(preference_device_id_cookie_name)

    # Step 3: Make request without refresh cookie
    assert_difference -> { AppPreference.count }, 1 do
      s.get(main_app_edge_v0_preference_url)
    end
    s.assert_response :success

    new_public_id = s.response.parsed_body.dig("preference", "public_id")
    new_refresh = s.cookies[preference_refresh_cookie_name]
    new_access = s.cookies[preference_access_cookie_name]

    # Verify new preference was created
    assert_not_equal original_public_id, new_public_id, "Should create new preference with different public_id"
    assert_predicate new_refresh, :present?, "Should have new refresh cookie"
    assert_predicate new_access, :present?, "Should have new access cookie"

    # Verify both preferences exist in DB
    assert AppPreference.exists?(public_id: original_public_id), "Original preference should still exist"
    assert AppPreference.exists?(public_id: new_public_id), "New preference should exist"
  end

  test "when only preference_refresh is cleared but access is valid, same preference continues" do
    s = open_session
    s.host!(@host)

    # First request - establish session
    s.get(main_app_edge_v0_preference_url)
    s.assert_response :success

    first_preference_id = s.response.parsed_body.dig("preference", "public_id")

    # Clear only refresh cookie (but access token remains valid)
    s.cookies.delete(preference_refresh_cookie_name)

    # Next request - access token is still valid, so same preference continues
    s.get(main_app_edge_v0_preference_url)
    s.assert_response :success

    second_preference_id = s.response.parsed_body.dig("preference", "public_id")

    # Same preference should be used because access token is still valid
    assert_equal first_preference_id, second_preference_id, "Same preference should continue when access token is valid"
  end

  test "when both access and refresh are cleared, new preference is created" do
    s = open_session
    s.host!(@host)

    # First request - establish session
    s.get(main_app_edge_v0_preference_url)
    s.assert_response :success

    first_preference_id = s.response.parsed_body.dig("preference", "public_id")

    # Clear both access and refresh cookies
    s.cookies.delete(preference_access_cookie_name)
    s.cookies.delete(preference_refresh_cookie_name)

    # Next request should create new preference
    assert_difference -> { AppPreference.count }, 1 do
      s.get(main_app_edge_v0_preference_url)
    end
    s.assert_response :success

    second_preference_id = s.response.parsed_body.dig("preference", "public_id")

    # New preference should be created
    assert_not_equal first_preference_id, second_preference_id

    # Verify new cookies are set
    assert_predicate s.cookies[preference_refresh_cookie_name], :present?
    assert_predicate s.cookies[preference_access_cookie_name], :present?
  end

  private

  def preference_access_cookie_name
    Preference::CookieName.access
  end

  def preference_refresh_cookie_name
    Preference::CookieName.refresh
  end

  def preference_device_id_cookie_name
    Preference::CookieName.device(refresh_cookie_key: preference_refresh_cookie_name)
  end

  def main_app_edge_v0_preference_url
    "http://#{@host}/edge/v0/preference"
  end
end
