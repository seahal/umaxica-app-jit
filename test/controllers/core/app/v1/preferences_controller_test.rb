# frozen_string_literal: true

require "test_helper"

module Core
  module App
    module V1
      class PreferenceControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = app_preferences(:one)
        end

        test "should get show with existing preference" do
          # First request to get a preference and cookie
          get core_app_v1_preference_url
          assert_response :success
          first_json = response.parsed_body
          first_public_id = first_json["preference"]["public_id"]

          # Second request should use the cookie from the first request
          get core_app_v1_preference_url
          assert_response :success
          second_json = response.parsed_body
          assert_equal first_public_id, second_json["preference"]["public_id"]

          assert_equal "ja", second_json["preference"]["lx"]
          assert_equal "sy", second_json["preference"]["ct"]
          assert_equal "jp", second_json["preference"]["ri"]
          assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
        end

        test "should create new preference when cookie is missing" do
          assert_difference -> { AppPreference.count }, 1 do
            assert_difference -> { AppPreferenceAudit.count }, 2 do
              get core_app_v1_preference_url
              assert_response :success
            end
          end

          json = response.parsed_body
          assert_predicate json["preference"]["public_id"], :present?
          assert_equal "ja", json["preference"]["lx"]
          assert_equal "sy", json["preference"]["ct"]
          assert_equal "jp", json["preference"]["ri"]
          assert_equal "Asia/Tokyo", json["preference"]["tz"]
        end

        test "should create audit log with CREATE_NEW_PREFERENCE_TOKEN event" do
          get core_app_v1_preference_url
          assert_response :success

          audit = AppPreferenceAudit.where(event_id: "CREATE_NEW_PREFERENCE_TOKEN").order(:created_at).last
          assert_predicate audit, :present?
          assert_equal "CREATE_NEW_PREFERENCE_TOKEN", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "AppPreference", audit.subject_type
        end

        test "should store encrypted token in cookies" do
          get core_app_v1_preference_url
          assert_response :success

          assert_predicate cookies[preference_refresh_cookie_name], :present?, "Refresh cookie should be set"
          assert_predicate cookies[preference_access_cookie_name], :present?, "Access cookie should be set"
        end

        test "should rotate refresh token when access token is missing" do
          get core_app_v1_preference_url
          assert_response :success

          preference_public_id = response.parsed_body["preference"]["public_id"]
          preference = AppPreference.find_by(public_id: preference_public_id)
          assert_predicate preference, :present?, "Preference from response should exist"

          old_refresh = cookies[preference_refresh_cookie_name]
          assert_predicate old_refresh, :present?
          old_jti = preference.jti

          cookies.delete(preference_access_cookie_name)

          get core_app_v1_preference_url
          assert_response :success

          new_refresh = cookies[preference_refresh_cookie_name]
          assert_predicate new_refresh, :present?
          assert_not_equal old_refresh, new_refresh
          assert_predicate cookies[preference_access_cookie_name], :present?, "Access cookie should be set"
          preference.reload
          assert_not_equal old_jti, preference.jti, "jti should rotate when access token is reissued"
        end

        test "should return JSON with correct structure" do
          get core_app_v1_preference_url
          assert_response :success

          json = response.parsed_body
          assert json.key?("preference")
          assert_equal 5, json["preference"].keys.size
          assert json["preference"].key?("public_id")
          assert json["preference"].key?("lx")
          assert json["preference"].key?("ct")
          assert json["preference"].key?("ri")
          assert json["preference"].key?("tz")
        end

        test "should not create duplicate preference for same cookie" do
          get core_app_v1_preference_url
          assert_response :success

          assert_no_difference -> { AppPreference.count } do
            get core_app_v1_preference_url
            assert_response :success
          end
        end

        test "should create preference options when creating new preference" do
          assert_difference(
            [
              -> { AppPreference.count },
              -> { AppPreferenceCookie.count },
              -> { AppPreferenceTimezone.count },
              -> { AppPreferenceLanguage.count },
              -> { AppPreferenceRegion.count },
              -> { AppPreferenceColortheme.count },
            ],
            1,
          ) do
            get core_app_v1_preference_url
            assert_response :success
          end
        end

        test "should create all preference associations" do
          get core_app_v1_preference_url
          preference = AppPreference.order(:created_at).last

          assert_predicate preference.app_preference_cookie, :present?
          assert_predicate preference.app_preference_timezone, :present?
          assert_predicate preference.app_preference_language, :present?
          assert_predicate preference.app_preference_region, :present?
          assert_predicate preference.app_preference_colortheme, :present?
        end

        test "should create cookie preference with correct default values" do
          get core_app_v1_preference_url
          preference = AppPreference.order(:created_at).last
          cookie = preference.app_preference_cookie

          assert_not cookie.targetable
          assert_not cookie.performant
          assert_not cookie.functional
        end

        test "should create preference with jti for token revocation" do
          get core_app_v1_preference_url
          assert_response :success

          preference = AppPreference.order(:created_at).last
          expected_length = Jwt::Jti.encoded_length(Jwt::Jti::DEFAULT_BYTES)
          assert_predicate preference.jti, :present?, "jti should be set for new preferences"
          assert_match(Jwt::Jti::BASE64URL_REGEX, preference.jti, "jti should be base64url-safe")
          assert_equal expected_length, preference.jti.length,
                       "jti should be #{expected_length} chars for #{Jwt::Jti::DEFAULT_BYTES} bytes"
          assert_no_match(/\A[0-9a-f-]{36}\z/i, preference.jti, "jti should not remain a UUID")
        end

        test "should set access token cookie after creating preference" do
          get core_app_v1_preference_url
          assert_response :success

          # Verify access token cookie is set (JWT decoding tested in token tests)
          access_token = cookies[preference_access_cookie_name]
          assert_predicate access_token, :present?, "Access token cookie should be set"

          # Verify the preference has jti set
          preference = AppPreference.order(:created_at).last
          assert_predicate preference.jti, :present?, "Preference should have jti for token revocation"
        end
      end
    end
  end
end
