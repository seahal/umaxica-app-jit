# frozen_string_literal: true

require "test_helper"

module Apex
  module Org
    module Preference
      class RegionsControllerTest < ActionDispatch::IntegrationTest
        setup do
          host! ENV.fetch("APEX_ORGANIZATION_URL", "org.localhost")
          https!

          @preference = org_preferences(:one)
          # Ensure region preference exists
          @preference_region = OrgPreferenceRegion.find_by(preference_id: @preference.id) ||
            OrgPreferenceRegion.create!(preference_id: @preference.id, option_id: "US")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_org_preference_region_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_region[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update region preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          initial_count = OrgPreferenceAudit.count

          patch apex_org_preference_region_url,
                params: {
                  preference_region: {
                    option_id: "JP",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, OrgPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/region/edit}

          @preference_region.reload
          assert_equal "JP", @preference_region.option_id

          audit = OrgPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_REGION", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "OrgPreference", audit.subject_type
        end
      end
    end
  end
end
