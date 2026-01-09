# frozen_string_literal: true

require "test_helper"

module Core
  module Com
    module V1
      class PreferencesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = com_preferences(:one)
        end

        test "should get show with existing preference" do
          # First request to get a preference and cookie
          get core_com_v1_preference_url
          assert_response :success
          first_json = response.parsed_body
          first_public_id = first_json["preference"]["public_id"]

          # Second request should use the cookie from the first request
          get core_com_v1_preference_url
          assert_response :success
          second_json = response.parsed_body
          assert_equal first_public_id, second_json["preference"]["public_id"]

          assert_equal "JA", second_json["preference"]["lx"]
          assert_equal "system", second_json["preference"]["ct"]
          assert_equal "JP", second_json["preference"]["ri"]
          assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
        end

        test "should create new preference when cookie is missing" do
          assert_difference -> { ComPreference.count }, 1 do
            assert_difference -> { ComPreferenceAudit.count }, 1 do
              get core_com_v1_preference_url
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
          get core_com_v1_preference_url
          assert_response :success

          audit = ComPreferenceAudit.last
          assert_equal "CREATE_NEW_PREFERENCE_TOKEN", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "ComPreference", audit.subject_type
        end

        test "should store encrypted token in cookie" do
          get core_com_v1_preference_url
          assert_response :success

          assert_predicate cookies["Jit-Preference"], :present?, "Cookie should be set"
        end

        test "should return JSON with correct structure" do
          get core_com_v1_preference_url
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
          get core_com_v1_preference_url
          assert_response :success

          assert_no_difference -> { ComPreference.count } do
            get core_com_v1_preference_url
            assert_response :success
          end
        end
      end
    end
  end
end
