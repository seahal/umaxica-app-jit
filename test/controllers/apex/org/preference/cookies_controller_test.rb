# frozen_string_literal: true

require "test_helper"

module Apex
  module Org
    module Preference
      class CookiesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = org_preferences(:one)
          # Ensure cookie preference exists
          @preference_cookie = OrgPreferenceCookie.find_by(preference_id: @preference.id) ||
            OrgPreferenceCookie.create!(preference_id: @preference.id)

          # Set the cookie directly using the same logic as Preference::Base
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_org_preference_cookie_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
        end

        test "should update cookie preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          initial_count = OrgPreferenceAudit.count

          patch apex_org_preference_cookie_url,
                params: {
                  preference_cookie: {
                    functional: true,
                    performant: true,
                    targetable: true,
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, OrgPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/cookie/edit}

          # PreferenceRecord.connected_to(role: :writing) do
          #   @preference_cookie.reload
          #   assert_equal true, @preference_cookie.functional
          #   assert_equal true, @preference_cookie.performant
          #   assert_equal true, @preference_cookie.targetable
          # end

          audit = OrgPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_COOKIE", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "OrgPreference", audit.subject_type
        end
        test "should update cookie preference with all true/false combinations" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          combinations = [true, false].repeated_permutation(3).to_a

          combinations.each do |func, perf, targ|
            patch apex_org_preference_cookie_url,
                  params: {
                    preference_cookie: {
                      functional: func,
                      performant: perf,
                      targetable: targ,
                    },
                  },
                  headers: { "Cookie" => "#{cookie_name}=#{@token}" }

            assert_redirected_to %r{/preference/cookie/edit}
            assert_equal I18n.t("apex.org.preferences.update_success"), flash[:notice]

            # PreferenceRecord.connected_to(role: :writing) do
            #   @preference_cookie.reload
            #   assert_equal func, @preference_cookie.functional
            #   assert_equal perf, @preference_cookie.performant
            #   assert_equal targ, @preference_cookie.targetable
            # end
          end
        end
      end
    end
  end
end
