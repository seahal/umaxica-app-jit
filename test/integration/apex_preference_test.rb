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

    test "#{domain[:name]} domain redirects to add ri param when missing" do
      host!(domain[:host])

      # Visit URL without ri parameter
      get public_send("apex_#{domain[:name]}_preference_url")

      # Should redirect to include ri=jp
      assert_redirected_to public_send("apex_#{domain[:name]}_preference_url", ri: "jp")
    end

    test "#{domain[:name]} domain does not redirect when ri param present" do
      host!(domain[:host])

      # Visit URL with ri parameter
      get public_send("apex_#{domain[:name]}_preference_url", ri: "us")

      # Should not redirect
      assert_response :success
    end

    test "#{domain[:name]} domain respects lx param for locale" do
      host!(domain[:host])

      # Visit URL with lx=en and ri=us
      get public_send("edit_apex_#{domain[:name]}_preference_cookie_url", lx: "en", ri: "us")

      # Should not redirect and locale should be set to English
      assert_response :success
      assert_equal :en, I18n.locale
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

    test "#{domain[:name]} domain applies language setting to locale" do
      host!(domain[:host])
      assert_preference_created(domain)

      # Update language to English
      state = default_state.merge(lx: "en")
      patch public_send("apex_#{domain[:name]}_preference_region_language_url", state),
            params: { preference_language: { option_id: "EN" } }

      # Visit a page without language param to verify DB preference is applied
      get public_send("apex_#{domain[:name]}_preference_url", ri: "jp")
      assert_response :success

      # Check that the locale was set to English
      assert_equal :en, I18n.locale
      # Verify the page content is in English
      translation_key = "apex.#{domain[:name]}.preferences.title"
      english_title = I18n.t(translation_key, locale: :en)
      assert_select "h1", text: english_title

      # Update language to Japanese
      state = default_state.merge(lx: "ja")
      patch public_send("apex_#{domain[:name]}_preference_region_language_url", state),
            params: { preference_language: { option_id: "JA" } }

      # Visit a page without language param to verify DB preference is applied
      get public_send("apex_#{domain[:name]}_preference_url", ri: "jp")
      assert_response :success

      # Check that the locale was set to Japanese
      assert_equal :ja, I18n.locale
      # Verify the page content is in Japanese
      japanese_title = I18n.t(translation_key, locale: :ja)
      assert_select "h1", text: japanese_title

      # Verify the translations are actually different
      assert_not_equal english_title, japanese_title
    end

    test "#{domain[:name]} domain applies timezone setting to Time.zone" do
      host!(domain[:host])
      assert_preference_created(domain)

      # Update timezone to UTC
      state = default_state.merge(tz: "etc/utc")
      patch public_send("apex_#{domain[:name]}_preference_region_timezone_url", state),
            params: { preference_timezone: { option_id: "Etc/UTC" } }

      # Visit a page to verify DB preference is applied to Time.zone
      get public_send("edit_apex_#{domain[:name]}_preference_region_timezone_url", default_state)
      assert_response :success
      assert_equal "Etc/UTC", Time.zone.name

      # Update timezone to Asia/Tokyo
      state = default_state.merge(tz: "asia/tokyo")
      patch public_send("apex_#{domain[:name]}_preference_region_timezone_url", state),
            params: { preference_timezone: { option_id: "Asia/Tokyo" } }

      # Visit a page to verify DB preference is applied to Time.zone
      get public_send("edit_apex_#{domain[:name]}_preference_region_timezone_url", default_state)
      assert_response :success
      assert_equal "Asia/Tokyo", Time.zone.name
    end

    test "#{domain[:name]} domain language select uses localized options" do
      host!(domain[:host])
      get public_send("edit_apex_#{domain[:name]}_preference_region_language_url", default_state)

      # We expect the native names for Japanese and English to appear in both locales
      assert_select "select[name='preference_language[option_id]']" do
        assert_select "option[value='JA']", text: "日本語"
        assert_select "option[value='EN']", text: "English"
      end
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

    test "#{domain[:name]} domain timezone select omits blank option" do
      host!(domain[:host])
      get public_send("edit_apex_#{domain[:name]}_preference_region_timezone_url", default_state)
      assert_select "select[name='preference_timezone[option_id]'] option[value='']", count: 0
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

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"), params: { confirm_reset: "1" }
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

    test "#{domain[:name]} domain reset without confirmation returns error" do
      host!(domain[:host])
      pref, = assert_preference_created(domain)
      original_expires_at = pref.expires_at

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp")
      assert_response :unprocessable_content

      assert_select ".bg-red-50" do
        assert_select "li"
      end

      pref.reload
      assert_equal "NEYO", pref.status_id
      assert_equal original_expires_at, pref.expires_at
    end

    test "#{domain[:name]} domain creates new preference after reset" do
      host!(domain[:host])
      pref, token, cookie_name = assert_preference_created(domain)

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"), params: { confirm_reset: "1" }

      get public_send("apex_#{domain[:name]}_preference_url", ri: "jp")
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
      state = { ri: "jp" }
      patch public_send("apex_#{domain[:name]}_preference_region_timezone_url", state),
            params: { preference_timezone: { option_id: "Invalid/Zone" } }

      # Expect redirect back to edit with current params
      assert_redirected_to public_send("edit_apex_#{domain[:name]}_preference_region_timezone_url", state)
      assert_equal I18n.t("errors.messages.preference_operation_failed"), flash[:alert]
    end

    test "#{domain[:name]} domain timezone edit links to region edit" do
      host!(domain[:host])

      get public_send("edit_apex_#{domain[:name]}_preference_region_timezone_url", default_state)
      assert_response :success

      assert_select "a[href^=?]", public_send("edit_apex_#{domain[:name]}_preference_region_path")
    end

    test "#{domain[:name]} domain language edit links to region edit" do
      host!(domain[:host])

      get public_send("edit_apex_#{domain[:name]}_preference_region_language_url", default_state)
      assert_response :success

      assert_select "a[href^=?]", public_send("edit_apex_#{domain[:name]}_preference_region_path")
    end

    test "#{domain[:name]} domain region edit links to timezone and language with params" do
      host!(domain[:host])
      state = { ri: "jp", lx: "ja" }

      get public_send("edit_apex_#{domain[:name]}_preference_region_url", state)
      assert_response :success

      assert_select "a[href=?]", public_send("edit_apex_#{domain[:name]}_preference_region_timezone_path", state)
      assert_select "a[href=?]", public_send("edit_apex_#{domain[:name]}_preference_region_language_path", state)
    end
  end

  DOMAINS.each do |domain|
    test "#{domain[:name]} domain reset edit page has confirmation checkbox" do
      host!(domain[:host])
      assert_preference_created(domain)

      get public_send("edit_apex_#{domain[:name]}_preference_reset_url", ri: "jp")
      assert_response :success

      assert_select "input[type='checkbox'][name='confirm_reset'][required]"
      assert_select "label[for='confirm_reset']"
    end
  end

  private

  def default_state
    { ri: "jp" }
  end

  def assert_preference_created(domain)
    get public_send("apex_#{domain[:name]}_preference_url", ri: "jp")
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
    suffix = preference_route_suffix(kind)
    get public_send("edit_apex_#{domain[:name]}_preference_#{suffix}_url", state)
    assert_response :success

    patch public_send("apex_#{domain[:name]}_preference_#{suffix}_url", state), params: params
    assert_redirected_to public_send("edit_apex_#{domain[:name]}_preference_#{suffix}_url", state)
    follow_redirect!

    assert_equal I18n.t(domain[:scope] + ".update_success"), flash[:notice]
  end

  def preference_route_suffix(kind)
    %i(language timezone).include?(kind) ? "region_#{kind}" : kind.to_s
  end
end
