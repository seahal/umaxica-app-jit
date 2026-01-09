# frozen_string_literal: true

require "test_helper"

module Apex
  module Com
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        setup do
          host! ENV.fetch("APEX_CORPORATE_URL", "com.localhost")
          https!

          @preference = com_preferences(:one)
          # Ensure colortheme preference exists
          @preference_colortheme = ComPreferenceColortheme.find_by(preference_id: @preference.id) ||
            ComPreferenceColortheme.create!(preference_id: @preference.id, option_id: "system")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_com_preference_theme_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_colortheme[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update theme preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"

          # Change option_id to ensure we're updating from a known state
          @preference_colortheme.update!(option_id: "light")

          # Make a GET request first to ensure all setup is complete
          get edit_apex_com_preference_theme_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          # Now count audits after all initialization
          initial_count = ComPreferenceAudit.count

          patch apex_com_preference_theme_url,
                params: {
                  preference_colortheme: {
                    option_id: "dark",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          # Expecting 1 audit log for the theme update
          audit_count = ComPreferenceAudit.count - initial_count

          # Debug: Print all new audit logs if count is unexpected
          if audit_count != 1
            new_audits = ComPreferenceAudit.where("created_at > ?", 5.seconds.ago).order(:created_at)
            puts "\nExpected 1 audit log but got #{audit_count}:"
            new_audits.each_with_index do |audit, i|
              puts(
                "  #{i + 1}. event_id: #{audit.event_id}, " \
                "level_id: #{audit.level_id}, subject_id: #{audit.subject_id}",
              )
            end
          end

          assert_equal 1, audit_count

          assert_redirected_to %r{/preference/theme/edit}

          @preference_colortheme.reload
          assert_equal "dark", @preference_colortheme.option_id

          audit = ComPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_COLORTHEME", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "ComPreference", audit.subject_type
        end
      end
    end
  end
end
