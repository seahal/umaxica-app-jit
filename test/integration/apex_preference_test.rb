# frozen_string_literal: true

require "test_helper"
require "sha3"

class ApexPreferenceTest < ActionDispatch::IntegrationTest
  setup do
    https!
  end

  DOMAINS = [
    { name: "app", host: "app.localhost", scope: "apex.app.preferences", preference_model: AppPreference },
    { name: "org", host: "org.localhost", scope: "apex.org.preferences", preference_model: OrgPreference },
    { name: "com", host: "com.localhost", scope: "apex.com.preferences", preference_model: ComPreference },
  ].freeze

  DOMAINS.each do |domain|
    test "#{domain[:name]} domain creates preference on index" do
      host!(domain[:host])

      pref, _token, _cookie_name = assert_preference_created(domain)
      assert_equal "NEYO", pref.status_id
    end

    test "#{domain[:name]} domain updates region" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      state = default_state.merge(ri: "us")
      assert_preference_update(
        domain,
        :region,
        { preference_region: { option_id: "US" } },
        state,
      )

      pref.reload
      assert_equal "US", pref.try("#{domain[:name]}_preference_region").option_id
    end

    test "#{domain[:name]} domain updates timezone" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      state = default_state.merge(tz: "etc/utc")
      update_option_id = "Etc/UTC"
      assert_preference_update(
        domain,
        :timezone,
        { preference_timezone: { option_id: update_option_id } },
        state,
      )

      pref.reload
      assert_equal update_option_id, pref.try("#{domain[:name]}_preference_timezone").option_id
    end

    test "#{domain[:name]} domain updates language" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      state = default_state.merge(lx: "en")
      assert_preference_update(
        domain,
        :language,
        { preference_language: { option_id: "EN" } },
        state,
      )

      pref.reload
      assert_equal "EN", pref.try("#{domain[:name]}_preference_language").option_id
    end

    test "#{domain[:name]} domain updates theme" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      state = default_state.merge(ct: "dark")
      assert_preference_update(
        domain,
        :theme,
        { preference_colortheme: { option_id: "dark" } },
        state,
      )

      pref.reload
      assert_equal "dark", pref.try("#{domain[:name]}_preference_colortheme").option_id
    end

    test "#{domain[:name]} domain updates cookie" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      assert_preference_update(
        domain,
        :cookie,
        { preference_cookie: { functional: "1" } },
        default_state,
      )

      pref.reload
      assert pref.try("#{domain[:name]}_preference_cookie").functional
    end

    test "#{domain[:name]} domain resets preferences" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)

      get public_send("edit_apex_#{domain[:name]}_preference_reset_url", default_state)
      assert_response :success

      delete public_send("apex_#{domain[:name]}_preference_reset_url")
      assert_redirected_to public_send(
        "edit_apex_#{domain[:name]}_preference_reset_url",
        default_state,
      )
      follow_redirect!

      assert_equal I18n.t("apex." + domain[:name] + ".preference.resets.destroyed"), flash[:notice]

      pref.reload
      assert_equal "DELETED", pref.status_id
      assert_not_nil pref.expires_at
    end

    test "#{domain[:name]} domain creates new preference after reset" do
      host!(domain[:host])
      pref, token, cookie_name = assert_preference_created(domain)

      delete public_send("apex_#{domain[:name]}_preference_reset_url")

      get public_send("apex_#{domain[:name]}_preference_url")
      assert_response :success

      new_token = cookies[cookie_name]
      assert_not_equal token, new_token

      new_token_digest = SHA3::Digest::SHA3_384.digest(new_token)
      new_pref = domain[:preference_model].find_by(token_digest: new_token_digest)
      assert_not_equal pref.id, new_pref.id
      assert_equal "NEYO", new_pref.status_id
    end

    test "#{domain[:name]} domain surfaces localized timezone errors" do
      host!(domain[:host])
      state = { ct: "sy", lx: "ja", ri: "jp", tz: "jst" }
      patch public_send("apex_#{domain[:name]}_preference_timezone_url", state),
            params: { preference_timezone: { option_id: "Invalid/Zone" } }

      # Expect redirect back to edit with current params
      assert_redirected_to public_send("edit_apex_#{domain[:name]}_preference_timezone_url", state)
      assert_equal I18n.t("errors.messages.preference_operation_failed"), flash[:alert]
    end
  end

  private

  def default_state
    { ct: "sy", lx: "ja", ri: "jp", tz: "jst" }
  end

  def assert_preference_created(domain)
    get public_send("apex_#{domain[:name]}_preference_url")
    assert_response :success

    cookie_name = "Jit-Preference"
    token = cookies[cookie_name]
    assert_not_nil token
    token_digest = SHA3::Digest::SHA3_384.digest(token)
    pref = domain[:preference_model].find_by(token_digest: token_digest)
    assert_not_nil pref
    [pref, token, cookie_name]
  end

  def assert_preference_update(domain, kind, params, state)
    get public_send("edit_apex_#{domain[:name]}_preference_#{kind}_url", state)
    assert_response :success

    patch public_send("apex_#{domain[:name]}_preference_#{kind}_url", state), params: params
    assert_redirected_to public_send("edit_apex_#{domain[:name]}_preference_#{kind}_url", state)
    follow_redirect!

    assert_equal I18n.t(domain[:scope] + ".update_success"), flash[:notice]
  end
end
