# typed: false
# frozen_string_literal: true

require "test_helper"
require "sha3"

class ApexPreferenceResetTest < ActionDispatch::IntegrationTest
  setup do
    https!
  end

  DOMAINS = [
    {
      name: "app",
      host: "app.localhost",
      scope: "apex.app.preferences",
      preference_model: AppPreference,
      audit_class: AppPreferenceActivity,
      audit_event_class: AppPreferenceActivityEvent,
    },
    {
      name: "org",
      host: "org.localhost",
      scope: "apex.org.preferences",
      preference_model: OrgPreference,
      audit_class: OrgPreferenceActivity,
      audit_event_class: OrgPreferenceActivityEvent,
    },
    {
      name: "com",
      host: "com.localhost",
      scope: "apex.com.preferences",
      preference_model: ComPreference,
      audit_class: ComPreferenceActivity,
      audit_event_class: ComPreferenceActivityEvent,
    },
  ].freeze

  DOMAINS.each do |domain|
    test "#{domain[:name]} domain reset edit page has confirmation checkbox" do
      host!(domain[:host])

      assert_preference_created(domain)

      get public_send("edit_apex_#{domain[:name]}_preference_reset_url", ri: "jp")

      assert_response :success
      assert_select "input[type='checkbox'][name='confirm_reset'][required]"
      assert_select "label[for='confirm_reset']"
    end

    test "#{domain[:name]} domain reset destroy updates preference status to DELETED" do
      host!(domain[:host])
      pref, _token, _cookie_name = assert_preference_created(domain)
      audit_class = domain[:audit_class]

      initial_status = pref.status_id
      initial_audit_count = audit_class.where(subject_id: pref.id).count

      assert_equal 2, initial_status, "Initial status should be NOTHING"

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"),
             params: { confirm_reset: "1" }

      assert_redirected_to public_send("edit_apex_#{domain[:name]}_preference_reset_url", ri: "jp")

      pref.reload
      final_audit_count = audit_class.where(subject_id: pref.id).count

      assert_equal 1, pref.status_id, "Status should be DELETED after reset"
      assert_operator final_audit_count, :>, initial_audit_count, "Audit log should be created"

      event_class = domain[:audit_event_class]
      audit = audit_class.where(subject_id: pref.id).order(id: :desc).first

      assert_equal event_class::RESET_BY_USER_DECISION, audit.event_id
    end

    test "#{domain[:name]} domain reset destroy deletes preference cookies" do
      host!(domain[:host])
      _pref, _token, cookie_name = assert_preference_created(domain)

      cookies[Preference::Base::THEME_COOKIE_KEY] = "dr"
      cookies[Preference::Base::LEGACY_THEME_COOKIE_KEY] = "dark"
      cookies[Preference::Base::LANGUAGE_COOKIE_KEY] = "en"
      cookies[Preference::Base::TIMEZONE_COOKIE_KEY] = "etc/utc"

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"),
             params: { confirm_reset: "1" }

      cookie_names = [
        cookie_name,
        preference_access_cookie_name,
        Preference::Base::THEME_COOKIE_KEY,
        Preference::Base::LEGACY_THEME_COOKIE_KEY,
        Preference::Base::LANGUAGE_COOKIE_KEY,
        Preference::Base::TIMEZONE_COOKIE_KEY,
      ].uniq

      assert cookie_names.all? { |name| cookies[name].to_s.empty? },
             "Preference-related cookies should be deleted"
    end

    test "#{domain[:name]} domain reset destroy fails without confirmation" do
      host!(domain[:host])
      pref, _token, cookie_name = assert_preference_created(domain)

      delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"),
             params: { confirm_reset: "0" }

      assert_response :unprocessable_content

      pref.reload

      assert_equal 2, pref.status_id, "Status should remain NOTHING"
      assert_not_nil cookies[cookie_name], "Cookie should still exist"
    end

    test "#{domain[:name]} domain reset logs database operations" do
      host!(domain[:host])
      _, _token, _cookie_name = assert_preference_created(domain)

      queries = []
      callback = ->(event) { queries << event.payload[:sql] }
      ActiveSupport::Notifications.subscribe("sql.active_record", callback)

      begin
        delete public_send("apex_#{domain[:name]}_preference_reset_url", ri: "jp"),
               params: { confirm_reset: "1" }
      ensure
        ActiveSupport::Notifications.unsubscribe(callback)
      end

      update_queries = queries.select { |q| q.include?("UPDATE") && q.include?("preferences") }
      insert_queries = queries.select { |q| q.include?("INSERT") && q.include?("activit") }

      assert_not_empty update_queries, "Should have UPDATE query on preferences table"
      assert_not_empty insert_queries, "Should have INSERT query on activity table"
    end
  end

  private

  def assert_preference_created(domain)
    get public_send("apex_#{domain[:name]}_preference_url", ri: "jp")

    assert_response :success

    cookie_name = preference_refresh_cookie_name
    token = cookies[cookie_name]

    assert_not_nil token
    token_digest = refresh_token_digest_for(token)
    pref = domain[:preference_model].find_by(token_digest: token_digest)

    assert_not_nil pref
    [pref, token, cookie_name]
  end

  def refresh_token_digest_for(token)
    digest = OpenSSL::Digest.new("SHA3-256")

    OpenSSL::HMAC.hexdigest(digest, ENV.fetch("PREFERENCE_JWT_SECRET_KEY"), token)
  end
end
