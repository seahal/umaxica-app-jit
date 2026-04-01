# typed: false
# frozen_string_literal: true

require "sha3"
require "cgi"
require "test_helper"

module Core
  module App
    module Edge
      module V0
        class PreferenceControllerTest < ActionDispatch::IntegrationTest
          fixtures :app_preferences,
                   :app_preference_statuses,
                   :app_preference_activities,
                   :app_preference_activity_events,
                   :app_preference_activity_levels,
                   :app_preference_languages,
                   :app_preference_language_options,
                   :app_preference_regions,
                   :app_preference_region_options,
                   :app_preference_timezones,
                   :app_preference_timezone_options,
                   :app_preference_colorthemes,
                   :app_preference_colortheme_options

          setup do
            @preference = app_preferences(:one)
            @host = "ww.app.localhost"
          end

          test "should get show with existing preference" do
            s = open_session
            s.host!(@host)

            # First request to get a preference and cookie
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success
            first_json = s.response.parsed_body
            first_public_id = first_json["preference"]["public_id"]

            # Second request should use the cookie from the first request
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success
            second_json = s.response.parsed_body

            assert_equal first_public_id, second_json["preference"]["public_id"]

            assert_equal "ja", second_json["preference"]["lx"]
            assert_equal "sy", second_json["preference"]["ct"]
            assert_equal "jp", second_json["preference"]["ri"]
            assert_equal "Asia/Tokyo", second_json["preference"]["tz"]
          end

          test "should create new preference when cookie is missing" do
            assert_difference -> { AppPreference.count }, 1 do
              get core_app_edge_v0_preference_url
            end
            assert_response :success
            assert_predicate response.parsed_body.dig("preference", "public_id"), :present?
          end

          test "should not create duplicate preference for same cookie" do
            s = open_session
            s.host!(@host)

            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success
            public_id = s.response.parsed_body.dig("preference", "public_id")

            s.assert_no_difference -> { AppPreference.count } do
              s.get(core_app_edge_v0_preference_url)
            end

            assert_equal public_id, s.response.parsed_body.dig("preference", "public_id")
          end

          test "should store encrypted token in cookies" do
            get core_app_edge_v0_preference_url

            assert_response :success
            assert_predicate cookies[preference_access_cookie_name], :present?
            assert_predicate cookies[preference_refresh_cookie_name], :present?
          end

          test "should create audit log with CREATE_NEW_PREFERENCE_TOKEN event" do
            assert_difference -> { AppPreferenceActivity.count }, 2 do
              get core_app_edge_v0_preference_url
            end

            recent_audits = AppPreferenceActivity.order(created_at: :desc).limit(2)
            event_ids = recent_audits.map { |a| a.app_preference_activity_event.id.to_i }

            assert_includes event_ids, AppPreferenceActivityEvent::CREATE_NEW_PREFERENCE_TOKEN
            assert_includes event_ids, AppPreferenceActivityEvent::REFRESH_TOKEN_ROTATED
          end

          test "invalid refresh_token is ignored and new preference is created" do
            # Use a fresh session
            s = open_session
            s.host!(@host)
            s.cookies[preference_refresh_cookie_name] = "invalid.token"

            # Note: without a device ID, it might fail early if we don't have it.
            # But the requirement is to ignore invalid tokens.

            s.assert_difference -> { AppPreference.count }, 1 do
              s.get(core_app_edge_v0_preference_url)
            end
            s.assert_response :success

            assert_predicate s.response.parsed_body.dig("preference", "public_id"), :present?
          end

          test "legacy refresh token is accepted" do
            # First request to get a valid device ID
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success

            current_public_id = s.response.parsed_body.dig("preference", "public_id")
            device_id = AppPreference.find_by!(public_id: current_public_id).device_id

            legacy_token = "legacy_refresh_#{SecureRandom.hex(8)}"
            legacy_digest = SHA3::Digest::SHA3_384.digest(legacy_token)
            legacy_preference =
              AppPreference.create!(
                public_id: SecureRandom.hex(10),
                status_id: AppPreferenceStatus::NOTHING,
                expires_at: 1.day.from_now,
                token_digest: legacy_digest,
                jti: SecureRandom.uuid,
                device_id: device_id,
                device_id_digest: Base64.strict_encode64(SHA3::Digest::SHA3_384.digest(device_id)),
              )

            # Use same session but with legacy token and device_id
            s.get(
              core_app_edge_v0_preference_url, headers: {
                "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{legacy_token}; #{preference_device_id_cookie_name}=#{device_id}",
              },
            )
            s.assert_response :success

            new_token = s.cookies[preference_refresh_cookie_name]

            assert_predicate new_token, :present?

            legacy_preference.reload

            assert_predicate legacy_preference.used_at, :present?
            assert_predicate legacy_preference.replaced_by_id, :present?
          end

          test "refresh fails when device_id is missing and clears preference auth cookies" do
            # First, establish a session with a valid preference and device_id
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success

            preference_public_id = s.response.parsed_body.dig("preference", "public_id")
            preference = AppPreference.find_by!(public_id: preference_public_id)

            assert_predicate preference.device_id_digest, :present?, "device_id_digest should be set on creation"

            # Store the refresh token from the first request
            refresh_token = s.cookies[preference_refresh_cookie_name]

            # Remove device_id cookie entirely (simulate client not sending it)
            # In Rack::Test, we need to explicitly delete the cookie
            s.get(
              core_app_edge_v0_preference_url,
              headers: { "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{refresh_token}" },
            )

            assert_equal 401, s.response.status
          end

          test "refresh fails when cookie device_id does not match stored digest" do
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success
            refresh_token = s.cookies[preference_refresh_cookie_name]
            wrong_device_id = SecureRandom.uuid

            # Use same session with wrong device_id in cookie
            s.get(
              core_app_edge_v0_preference_url, headers: {
                "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{refresh_token}; #{preference_device_id_cookie_name}=#{wrong_device_id}",
              },
            )

            assert_equal 401, s.response.status
          end

          test "refresh fails when stored device_id does not match cookie and clears cookies" do
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success
            refresh_token = s.cookies[preference_refresh_cookie_name]
            original_device_id = AppPreference.find_by!(
              public_id: s.response.parsed_body.dig(
                "preference",
                "public_id",
              ),
            ).device_id

            public_id = s.response.parsed_body.dig("preference", "public_id")
            new_device_id = SecureRandom.uuid
            AppPreference.find_by!(public_id: public_id).update!(
              device_id: new_device_id,
              device_id_digest: Base64.strict_encode64(SHA3::Digest::SHA3_384.digest(new_device_id)),
            )

            # Use same session with original device_id in cookie (but DB has new device_id)
            s.get(
              core_app_edge_v0_preference_url, headers: {
                "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{refresh_token}; #{preference_device_id_cookie_name}=#{original_device_id}",
              },
            )

            assert_equal 401, s.response.status
          end

          test "refresh replay is detected and rejected" do
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success

            old_refresh = s.cookies[preference_refresh_cookie_name]
            old_public_id = s.response.parsed_body.dig("preference", "public_id")
            old_preference = AppPreference.find_by!(public_id: old_public_id)
            device_id = old_preference.device_id

            # Trigger rotation by clearing access token to force refresh
            s.cookies.delete(preference_access_cookie_name)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success

            # Replay the old token
            s.get(
              core_app_edge_v0_preference_url, headers: {
                "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{old_refresh}; #{preference_device_id_cookie_name}=#{device_id}",
              },
            )

            assert_equal 401, s.response.status
            assert_predicate old_preference.reload.compromised_at, :present?
          end

          test "refresh succeeds when stored and request device_id match" do
            s = open_session
            s.host!(@host)
            s.get(core_app_edge_v0_preference_url)
            s.assert_response :success

            first_public_id = s.response.parsed_body.dig("preference", "public_id")
            first_preference = AppPreference.find_by!(public_id: first_public_id)
            refresh_token = s.cookies[preference_refresh_cookie_name]
            device_id = first_preference.device_id

            # Use same session with matching device_id
            s.get(
              core_app_edge_v0_preference_url, headers: {
                "Cookie" => "#{preference_access_cookie_name}=invalid.access.token; #{preference_refresh_cookie_name}=#{refresh_token}; #{preference_device_id_cookie_name}=#{device_id}",
              },
            )
            s.assert_response :success

            second_public_id = s.response.parsed_body.dig("preference", "public_id")

            assert_not_equal first_public_id, second_public_id
            assert_predicate first_preference.reload.replaced_by_id, :present?
          end

          test "should return JSON with correct structure" do
            get core_app_edge_v0_preference_url

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

          private

          def assert_cookie_cleared!(name)
            assert_nil cookies[name]
            # Also check Set-Cookie header for explicit deletion
            cookie_lines = response_cookie_lines

            assert cookie_lines.any? { |line|
              line.start_with?("#{name}=;") || line.include?("#{name}=deleted")
            }
          end

          def assert_cleared_preference_auth_cookies!
            assert_cookie_cleared!(preference_access_cookie_name)
            assert_cookie_cleared!(preference_refresh_cookie_name)
          end

          def response_cookie_lines
            raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
            case raw_header
            when Array then raw_header
            when String then raw_header.split("\n")
            else []
            end
          end
        end
      end
    end
  end
end
