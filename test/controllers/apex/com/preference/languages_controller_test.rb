# frozen_string_literal: true

require "test_helper"

module Apex
  module Com
    module Preference
      class LanguagesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @preference = com_preferences(:one)
          # Ensure language preference exists
          @preference_language = ComPreferenceLanguage.find_by(preference_id: @preference.id) ||
            ComPreferenceLanguage.create!(preference_id: @preference.id, option_id: "EN")

          # Set the cookie
          @token = SecureRandom.urlsafe_base64(48)
          token_digest = SHA3::Digest::SHA3_384.digest(@token)
          @preference.update!(token_digest: token_digest)
        end

        test "should get edit" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          get edit_apex_com_preference_language_url, headers: { "Cookie" => "#{cookie_name}=#{@token}" }
          assert_response :success
          assert_select "select[name='preference_language[option_id]']"
          assert_select "input[type='submit'][data-turbo-submits-with='送信中...']"
        end

        test "should update language preference and create audit log" do
          cookie_name = Rails.env.production? ? "__Secure-Jit-Preference" : "Jit-Preference"
          initial_count = ComPreferenceAudit.count

          patch apex_com_preference_language_url,
                params: {
                  preference_language: {
                    option_id: "JA",
                  },
                },
                headers: { "Cookie" => "#{cookie_name}=#{@token}" }

          assert_equal 1, ComPreferenceAudit.count - initial_count

          assert_redirected_to %r{/preference/language/edit}

          @preference_language.reload
          assert_equal "JA", @preference_language.option_id

          audit = ComPreferenceAudit.order(:created_at).last
          assert_equal "UPDATE_PREFERENCE_LANGUAGE", audit.event_id
          assert_equal "INFO", audit.level_id
          assert_equal "ComPreference", audit.subject_type
        end
      end
    end
  end
end
