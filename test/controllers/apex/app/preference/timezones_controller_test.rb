# frozen_string_literal: true

require "test_helper"

module Apex
  module App
    module Preference
      class TimezonesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = app_preferences(:one)
          # Ensure timezone preference exists
          @preference_timezone = AppPreferenceTimezone.find_by(preference_id: @preference.id) ||
            AppPreferenceTimezone.create!(preference_id: @preference.id, option_id: "Etc/UTC")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_app_preference_timezone_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_timezone[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update timezone preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          initial_count = AppPreferenceAudit.count

          patch apex_app_preference_timezone_url,
                params: {
                  preference_timezone: {
                    option_id: "Asia/Tokyo",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, AppPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/timezone/edit}

          @preference_timezone.reload
          assert_equal "Asia/Tokyo", @preference_timezone.option_id

          audit = AppPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_TIMEZONE", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "AppPreference", audit.subject_type
        end
      end
    end
  end
end
