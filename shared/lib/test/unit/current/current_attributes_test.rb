# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentAttributesTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "reset clears all attributes" do
    user = users(:one)
    Current.actor = user
    Current.actor_type = :user
    Current.session = "session_123"
    Current.token = { "sub" => 1 }
    Current.domain = :app
    Current.preference = Current::Preference.new(language: "en")

    Current.reset

    assert_same Unauthenticated.instance, Current.actor
    assert_equal :unauthenticated, Current.actor_type
    assert_nil Current.session
    assert_nil Current.token
    assert_nil Current.domain
    assert_predicate Current.preference, :null?
  end

  test "user? and staff? reflect actor_type" do
    Current.actor_type = :staff

    assert_predicate Current, :staff?
    assert_not Current.user?
    assert_nil Current.user

    Current.actor_type = :user

    assert_predicate Current, :user?
    assert_not Current.staff?
    assert_nil Current.staff
  end

  test "user and staff return actor for matching actor_type" do
    user = users(:one)
    staff = staffs(:one)

    Current.actor = user
    Current.actor_type = :user

    assert_equal user, Current.user
    assert_nil Current.staff

    Current.actor = staff
    Current.actor_type = :staff

    assert_equal staff, Current.staff
    assert_nil Current.user
  end

  test "preference defaults to NULL" do
    assert_equal Current::Preference::NULL, Current.preference
    assert_predicate Current.preference, :null?
    assert_equal "ja", Current.preference.language
  end

  test "domain can be set" do
    Current.domain = :app

    assert_equal :app, Current.domain

    Current.domain = :org

    assert_equal :org, Current.domain
  end

  test "session can be set" do
    Current.session = "session_public_id"

    assert_equal "session_public_id", Current.session
  end

  test "token can be set" do
    payload = { "sub" => 42, "act" => "user" }
    Current.token = payload

    assert_equal payload, Current.token
  end

  test "actor accepts User instance" do
    user = users(:one)
    Current.actor = user

    assert_equal user, Current.actor
  end

  test "actor accepts Staff instance" do
    staff = staffs(:one)
    Current.actor = staff

    assert_equal staff, Current.actor
  end

  test "actor accepts Customer instance" do
    customer = create_verified_customer_with_email(email_address: "current-#{SecureRandom.hex(4)}@example.com")
    Current.actor = customer

    assert_equal customer, Current.actor
  ensure
    Current.reset
  end

  test "actor accepts Unauthenticated.instance" do
    Current.actor = Unauthenticated.instance

    assert_same Unauthenticated.instance, Current.actor
  end

  test "actor rejects string value" do
    assert_raises(ArgumentError) do
      Current.actor = "some_string"
    end
  end

  test "actor rejects symbol value" do
    assert_raises(ArgumentError) do
      Current.actor = :some_symbol
    end
  end

  test "actor rejects arbitrary object" do
    obj = Object.new
    assert_raises(ArgumentError) do
      Current.actor = obj
    end
  end

  test "actor rejects nil" do
    assert_raises(ArgumentError) do
      Current.actor = nil
    end
  end

  test "actor_type accepts :user" do
    Current.actor_type = :user

    assert_equal :user, Current.actor_type
  end

  test "actor_type accepts :staff" do
    Current.actor_type = :staff

    assert_equal :staff, Current.actor_type
  end

  test "actor_type accepts :customer" do
    Current.actor_type = :customer

    assert_equal :customer, Current.actor_type
  end

  test "actor_type accepts :unauthenticated" do
    Current.actor_type = :unauthenticated

    assert_equal :unauthenticated, Current.actor_type
  end

  test "actor_type rejects invalid symbol" do
    assert_raises(ArgumentError) do
      Current.actor_type = :invalid
    end
  end

  test "actor_type rejects string value" do
    assert_raises(ArgumentError) do
      Current.actor_type = "user"
    end
  end

  test "actor_type rejects nil" do
    assert_raises(ArgumentError) do
      Current.actor_type = nil
    end
  end

  # Current::Preference tests

  test "Preference NULL returns safe defaults" do
    pref = Current::Preference::NULL

    assert_predicate pref, :null?
    assert_equal "ja", pref.language
    assert_equal "jp", pref.region
    assert_equal "Asia/Tokyo", pref.timezone
    assert_equal "sy", pref.theme
    assert_equal :ja, pref.locale
    assert_predicate pref, :system_theme?
    assert_not pref.dark_mode?
    assert_not pref.light_mode?
  end

  test "Preference NULL cookie returns false for all consent flags" do
    cookie = Current::Preference::NULL.cookie

    assert_not cookie.consented?
    assert_not cookie.functional?
    assert_not cookie.performant?
    assert_not cookie.targetable?
    assert_nil cookie.consent_version
    assert_nil cookie.consented_at
  end

  test "Preference custom values override defaults" do
    pref = Current::Preference.new(
      language: "en",
      region: "us",
      timezone: "America/New_York",
      theme: "dr",
    )

    assert_not pref.null?
    assert_equal "en", pref.language
    assert_equal "us", pref.region
    assert_equal "America/New_York", pref.timezone
    assert_equal :en, pref.locale
    assert_predicate pref, :dark_mode?
    assert_not pref.system_theme?
  end

  test "Preference with cookie consent" do
    cookie = Current::Preference::Cookie.new(
      consented: true,
      functional: true,
      performant: false,
      targetable: false,
      consent_version: "v1",
      consented_at: Time.zone.parse("2026-01-01"),
    )
    pref = Current::Preference.new(cookie: cookie)

    assert_predicate pref.cookie, :consented?
    assert_predicate pref.cookie, :functional?
    assert_not pref.cookie.performant?
    assert_equal "v1", pref.cookie.consent_version
  end

  test "Preference is frozen" do
    pref = Current::Preference.new

    assert_predicate pref, :frozen?
  end

  test "Preference time_zone returns ActiveSupport::TimeZone" do
    pref = Current::Preference.new(timezone: "America/New_York")

    assert_instance_of ActiveSupport::TimeZone, pref.time_zone
    assert_equal "America/New_York", pref.time_zone.name
  end

  test "Preference time_zone falls back to Asia/Tokyo for unknown zone" do
    pref = Current::Preference.new(timezone: "Invalid/Zone")

    assert_equal "Asia/Tokyo", pref.time_zone.name
  end

  test "Preference to_h returns preference summary" do
    pref = Current::Preference.new(language: "en", theme: "li")

    h = pref.to_h

    assert_equal "en", h[:language]
    assert_equal "li", h[:theme]
    assert_not h[:consented]
  end

  test "Current.preference can be assigned" do
    custom = Current::Preference.new(language: "en")
    Current.preference = custom

    assert_equal "en", Current.preference.language
    assert_not Current.preference.null?
  end

  test "Preference.from_jwt returns NULL for nil input" do
    assert_equal Current::Preference::NULL, Current::Preference.from_jwt(nil)
  end

  test "Preference.from_jwt returns NULL for non-hash input" do
    assert_equal Current::Preference::NULL, Current::Preference.from_jwt("string")
    assert_equal Current::Preference::NULL, Current::Preference.from_jwt(123)
    assert_equal Current::Preference::NULL, Current::Preference.from_jwt([])
  end

  test "Preference.from_jwt constructs correct Preference from valid prf hash" do
    prf = { "lx" => "en", "ri" => "us", "tz" => "America/New_York", "ct" => "dr" }
    pref = Current::Preference.from_jwt(prf)

    assert_not pref.null?
    assert_equal "en", pref.language
    assert_equal "us", pref.region
    assert_equal "America/New_York", pref.timezone
    assert_equal "dr", pref.theme
  end

  test "Preference.from_jwt falls back to DEFAULTS for missing keys" do
    prf = { "lx" => "en" }
    pref = Current::Preference.from_jwt(prf)

    assert_equal "en", pref.language
    assert_equal "jp", pref.region
    assert_equal "Asia/Tokyo", pref.timezone
    assert_equal "sy", pref.theme
  end

  test "Preference.from_jwt handles empty hash" do
    pref = Current::Preference.from_jwt({})

    assert_equal "ja", pref.language
    assert_equal "jp", pref.region
    assert_equal "Asia/Tokyo", pref.timezone
    assert_equal "sy", pref.theme
  end

  test "Preference.from_jwt accepts cookie parameter" do
    cookie = Current::Preference::Cookie.new(
      consented: true,
      functional: true,
      performant: false,
      targetable: false,
      consent_version: "v1",
      consented_at: Time.zone.parse("2026-01-01"),
    )
    prf = { "lx" => "en" }
    pref = Current::Preference.from_jwt(prf, cookie: cookie)

    assert_predicate pref.cookie, :consented?
    assert_predicate pref.cookie, :functional?
  end

  test "Preference with_cookie keeps preference values and updates cookie state" do
    pref = Current::Preference.new(language: "en", region: "us", timezone: "America/New_York", theme: "dr")

    updated = pref.with_cookie(
      consented: true,
      functional: true,
      performant: false,
      targetable: true,
      consent_version: "v2",
    )

    assert_equal "en", updated.language
    assert_equal "us", updated.region
    assert_equal "America/New_York", updated.timezone
    assert_equal "dr", updated.theme
    assert_predicate updated.cookie, :consented?
    assert_predicate updated.cookie, :functional?
    assert_not updated.cookie.performant?
    assert_predicate updated.cookie, :targetable?
    assert_equal "v2", updated.cookie.consent_version
  end
end
