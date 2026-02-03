# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    module Edge
      module V1
        class PreferenceControllerTest < ActionDispatch::IntegrationTest
          fixtures :org_preferences,
                   :org_preference_statuses,
                   :org_preference_audits,
                   :org_preference_audit_events,
                   :org_preference_audit_levels,
                   :org_preference_languages,
                   :org_preference_language_options,
                   :org_preference_regions,
                   :org_preference_region_options,
                   :org_preference_timezones,
                   :org_preference_timezone_options,
                   :org_preference_colorthemes,
                   :org_preference_colortheme_options

          setup do
            @preference = org_preferences(:one)
          end

          test "should get show with existing preference" do
            # First request to get a preference and cookie
            get core_org_edge_v1_preference_url
            assert_response :success
            first_json = response.parsed_body
            first_public_id = first_json["preference"]["public_id"]

            # Second request should use the cookie from the first request
            get core_org_edge_v1_preference_url
            assert_response :success
            second_json = response.parsed_body
            assert_equal first_public_id, second_json["preference"]["public_id"]

            assert_equal "ja", second_json["preference"]["lx"]
            assert_equal "sy", second_json["preference"]["ct"]
            assert_equal "jp", second_json["preference"]["ri"]
            assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
          end

          test "should create new preference when cookie is missing" do
            assert_difference -> { OrgPreference.count }, 1 do
              assert_difference -> { OrgPreferenceAudit.count }, 2 do
                get core_org_edge_v1_preference_url
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
            get core_org_edge_v1_preference_url
            assert_response :success

            audit = OrgPreferenceAudit.where(event_id: OrgPreferenceAuditEvent::CREATE_NEW_PREFERENCE_TOKEN).order(:created_at).last
            assert_predicate audit, :present?
            assert_equal OrgPreferenceAuditEvent::CREATE_NEW_PREFERENCE_TOKEN, audit.event_id
            assert_equal OrgPreferenceAuditLevel::INFO, audit.level_id
            assert_equal "OrgPreference", audit.subject_type
          end

          test "should store encrypted token in cookies" do
            get core_org_edge_v1_preference_url
            assert_response :success

            assert_predicate cookies[preference_refresh_cookie_name], :present?, "Refresh cookie should be set"
            assert_predicate cookies[preference_access_cookie_name], :present?, "Access cookie should be set"
          end

          test "should return JSON with correct structure" do
            get core_org_edge_v1_preference_url
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
            get core_org_edge_v1_preference_url
            assert_response :success

            assert_no_difference -> { OrgPreference.count } do
              get core_org_edge_v1_preference_url
              assert_response :success
            end
          end
        end
      end
    end
  end
end
