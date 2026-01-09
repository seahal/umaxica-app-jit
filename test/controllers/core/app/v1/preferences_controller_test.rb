# frozen_string_literal: true

require "test_helper"

module Core
  module App
    module V1
      class PreferencesControllerTest < ActionDispatch::IntegrationTest
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

          assert_equal "JA", second_json["preference"]["lx"]
          assert_equal "system", second_json["preference"]["ct"]
          assert_equal "JP", second_json["preference"]["ri"]
          assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
        end

        test "should create new preference when cookie is missing" do
          assert_difference -> { AppPreference.count }, 1 do
            assert_difference -> { AppPreferenceAudit.count }, 1 do
              get core_app_v1_preference_url
              assert_response :success
            end
          end

          json = response.parsed_body
          assert_predicate json["preference"]["public_id"], :present?
          assert_equal "JA", json["preference"]["lx"]
          assert_equal "system", json["preference"]["ct"]
          assert_equal "JP", json["preference"]["ri"]
          assert_equal "Asia/Tokyo", json["preference"]["tz"]
        end

        test "should create audit log with CREATE_NEW_PREFERENCE_TOKEN event" do
          get core_app_v1_preference_url
          assert_response :success

          audit = AppPreferenceAudit.order(:created_at).last
          assert_equal "CREATE_NEW_PREFERENCE_TOKEN", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "AppPreference", audit.subject_type
        end

        test "should store encrypted token in cookie" do
          get core_app_v1_preference_url
          assert_response :success

          assert_predicate cookies["Jit-Preference"], :present?, "Cookie should be set"
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
      end
    end
  end
end
