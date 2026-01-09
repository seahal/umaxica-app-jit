# frozen_string_literal: true

require "test_helper"

module Apex
  module Org
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        setup do
          host! ENV.fetch("APEX_ORGANIZATION_URL", "org.localhost")
          https!

          @preference = org_preferences(:one)
          # Ensure colortheme preference exists
          @preference_colortheme = OrgPreferenceColortheme.find_by(preference_id: @preference.id) ||
            OrgPreferenceColortheme.create!(preference_id: @preference.id, option_id: "system")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_org_preference_theme_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_colortheme[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update theme preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"

          # Change option_id to ensure we're updating from a known state
          @preference_colortheme.update!(option_id: "light")

          # Make a GET request first to ensure all setup is complete
          get edit_apex_org_preference_theme_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          # Now count audits after all initialization
          initial_count = OrgPreferenceAudit.count

          patch apex_org_preference_theme_url,
                params: {
                  preference_colortheme: {
                    option_id: "dark",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, OrgPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/theme/edit}

          @preference_colortheme.reload
          assert_equal "dark", @preference_colortheme.option_id

          audit = OrgPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_COLORTHEME", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "OrgPreference", audit.subject_type
        end
      end
    end
  end
end
