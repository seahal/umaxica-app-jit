# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module Com
    module Edge
      module V1
        class PreferenceControllerTest < ActionDispatch::IntegrationTest
          fixtures :com_preferences,
                   :com_preference_statuses,
                   :com_preference_activities,
                   :com_preference_activity_events,
                   :com_preference_activity_levels,
                   :com_preference_languages,
                   :com_preference_language_options,
                   :com_preference_regions,
                   :com_preference_region_options,
                   :com_preference_timezones,
                   :com_preference_timezone_options,
                   :com_preference_colorthemes,
                   :com_preference_colortheme_options

          setup do
            @preference = com_preferences(:one)
          end

          test "should get show with existing preference" do
            # First request to get a preference and cookie
            get core_com_edge_v1_preference_url
            assert_response :success
            first_json = response.parsed_body
            first_public_id = first_json["preference"]["public_id"]

            # Second request should use the cookie from the first request
            get core_com_edge_v1_preference_url
            assert_response :success
            second_json = response.parsed_body
            assert_equal first_public_id, second_json["preference"]["public_id"]

            assert_equal "ja", second_json["preference"]["lx"]
            assert_equal "sy", second_json["preference"]["ct"]
            assert_equal "jp", second_json["preference"]["ri"]
            assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
          end

          test "should create new preference when cookie is missing" do
            assert_difference -> { ComPreference.count }, 1 do
              assert_difference -> { ComPreferenceActivity.count }, 2 do
                get core_com_edge_v1_preference_url
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
            get core_com_edge_v1_preference_url
            assert_response :success

            audit = ComPreferenceActivity.where(event_id: ComPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN).order(:created_at).last
            assert_predicate audit, :present?
            assert_equal ComPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN, audit.event_id
            assert_equal ComPreferenceActivityLevel::INFO, audit.level_id
            assert_equal "ComPreference", audit.subject_type
          end

          test "should store encrypted token in cookies" do
            get core_com_edge_v1_preference_url
            assert_response :success

            assert_predicate cookies[preference_refresh_cookie_name], :present?, "Refresh cookie should be set"
            assert_predicate cookies[preference_access_cookie_name], :present?, "Access cookie should be set"
          end

          test "should return JSON with correct structure" do
            get core_com_edge_v1_preference_url
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
            get core_com_edge_v1_preference_url
            assert_response :success

            assert_no_difference -> { ComPreference.count } do
              get core_com_edge_v1_preference_url
              assert_response :success
            end
          end
        end
      end
    end
  end
end
