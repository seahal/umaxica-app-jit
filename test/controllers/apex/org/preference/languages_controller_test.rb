# frozen_string_literal: true

require "test_helper"

module Apex
  module Org
    module Preference
      class LanguagesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = org_preferences(:one)
          # Ensure language preference exists
          @preference_language = OrgPreferenceLanguage.find_by(preference_id: @preference.id) ||
            OrgPreferenceLanguage.create!(preference_id: @preference.id, option_id: "EN")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_org_preference_language_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_language[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update language preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          initial_count = OrgPreferenceAudit.count

          patch apex_org_preference_language_url,
                params: {
                  preference_language: {
                    option_id: "JA",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, OrgPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/language/edit}

          @preference_language.reload
          assert_equal "JA", @preference_language.option_id

          audit = OrgPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_LANGUAGE", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "OrgPreference", audit.subject_type
        end
      end
    end
  end
end
