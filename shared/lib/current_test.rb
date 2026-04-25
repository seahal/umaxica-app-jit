# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "defaults actor to unauthenticated" do
    Current.reset

    assert_same Unauthenticated.instance, Current.actor
    assert_predicate Current, :unauthenticated?
    assert_not_predicate Current, :authenticated?
    assert_equal :unauthenticated, Current.actor_type
  end

  test "recognizes customer actor type" do
    customer = create_verified_customer_with_email(email_address: "current-#{SecureRandom.hex(4)}@example.com")

    Current.actor = customer
    Current.actor_type = :customer

    assert_predicate Current, :customer?
    assert_equal customer, Current.customer
    assert_predicate Current, :authenticated?
  ensure
    Current.reset
  end

  test "recognizes user actor type" do
    user = User.create!

    Current.actor = user
    Current.actor_type = :user

    assert_predicate Current, :user?
    assert_equal user, Current.user
    assert_predicate Current, :authenticated?
    assert_not_predicate Current, :staff?
    assert_not_predicate Current, :customer?
  ensure
    Current.reset
  end

  test "recognizes staff actor type" do
    staff = Staff.create!(status_id: StaffStatus::ACTIVE)

    Current.actor = staff
    Current.actor_type = :staff

    assert_predicate Current, :staff?
    assert_equal staff, Current.staff
    assert_predicate Current, :authenticated?
    assert_not_predicate Current, :user?
    assert_not_predicate Current, :customer?
  ensure
    Current.reset
  end

  test "preference defaults to NULL when not set" do
    Current.reset

    assert_predicate Current.preference, :null?
  ensure
    Current.reset
  end

  test "preference returns set value" do
    Current.reset
    pref = Current::Preference.new(language: "en", region: "us", timezone: "America/New_York", theme: "light")
    Current.preference = pref

    assert_equal "en", Current.preference.language
    assert_equal "us", Current.preference.region
    assert_equal "America/New_York", Current.preference.timezone
    assert_equal "light", Current.preference.theme
    assert_not_predicate Current.preference, :null?
  ensure
    Current.reset
  end

  test "surface defaults to com" do
    Current.reset

    assert_equal :com, Current.surface
  ensure
    Current.reset
  end

  test "surface can be set" do
    Current.reset
    Current.surface = :app

    assert_equal :app, Current.surface
  ensure
    Current.reset
  end

  test "realm defaults to www" do
    Current.reset

    assert_equal :www, Current.realm
  ensure
    Current.reset
  end

  test "realm can be set" do
    Current.reset
    Current.realm = :help

    assert_equal :help, Current.realm
  ensure
    Current.reset
  end

  test "request_id defaults to empty string" do
    Current.reset

    assert_equal "", Current.request_id
  ensure
    Current.reset
  end

  test "boundary_key combines realm and surface" do
    Current.reset
    Current.realm = :www
    Current.surface = :app

    assert_equal "www:app", Current.boundary_key
  ensure
    Current.reset
  end

  test "actor= raises for invalid actor type" do
    Current.reset

    assert_raises(ArgumentError) do
      Current.actor = "invalid"
    end
  ensure
    Current.reset
  end

  test "actor_type= raises for invalid type" do
    Current.reset

    assert_raises(ArgumentError) do
      Current.actor_type = :invalid
    end
  ensure
    Current.reset
  end

  test "preference locale returns correct locale" do
    Current.reset
    pref = Current::Preference.new(language: "ja")
    Current.preference = pref

    assert_equal :ja, Current.preference.locale
  ensure
    Current.reset
  end

  test "preference cookie methods" do
    Current.reset
    cookie = Current::Preference::NULL_COOKIE

    assert_not_predicate cookie, :consented?
    assert_not_predicate cookie, :functional?
    assert_not_predicate cookie, :performant?
    assert_not_predicate cookie, :targetable?
  ensure
    Current.reset
  end

  test "preference DEFAULTS are frozen" do
    assert_predicate Current::Preference::DEFAULTS, :frozen?
  ensure
    Current.reset
  end

  test "preference locale returns en for en language" do
    Current.reset
    pref = Current::Preference.new(language: "en")
    Current.preference = pref

    assert_equal :en, Current.preference.locale
  ensure
    Current.reset
  end

  test "preference locale returns symbol for unknown language" do
    Current.reset
    pref = Current::Preference.new(language: "ko")
    Current.preference = pref

    assert_equal :ko, Current.preference.locale
  ensure
    Current.reset
  end

  test "preference time_zone returns correct timezone" do
    Current.reset
    pref = Current::Preference.new(timezone: "America/New_York")
    Current.preference = pref

    assert_equal "America/New_York", Current.preference.time_zone.name
  ensure
    Current.reset
  end

  test "preference time_zone falls back to Asia/Tokyo for invalid timezone" do
    Current.reset
    pref = Current::Preference.new(timezone: "Invalid/Timezone")
    Current.preference = pref

    assert_equal "Asia/Tokyo", Current.preference.time_zone.name
  ensure
    Current.reset
  end

  test "preference dark_mode? returns true for dr theme" do
    Current.reset
    pref = Current::Preference.new(theme: "dr")
    Current.preference = pref

    assert_predicate Current.preference, :dark_mode?
    assert_not_predicate Current.preference, :light_mode?
    assert_not_predicate Current.preference, :system_theme?
  ensure
    Current.reset
  end

  test "preference light_mode? returns true for li theme" do
    Current.reset
    pref = Current::Preference.new(theme: "li")
    Current.preference = pref

    assert_predicate Current.preference, :light_mode?
    assert_not_predicate Current.preference, :dark_mode?
    assert_not_predicate Current.preference, :system_theme?
  ensure
    Current.reset
  end

  test "preference system_theme? returns true for sy theme" do
    Current.reset
    pref = Current::Preference.new(theme: "sy")
    Current.preference = pref

    assert_predicate Current.preference, :system_theme?
    assert_not_predicate Current.preference, :dark_mode?
    assert_not_predicate Current.preference, :light_mode?
  ensure
    Current.reset
  end

  test "preference to_h returns hash" do
    Current.reset
    cookie = Current::Preference::Cookie.new(
      consented: true, functional: false, performant: false, targetable: false,
      consent_version: "1", consented_at: Time.current,
    )
    pref = Current::Preference.new(language: "ja", region: "jp", timezone: "Asia/Tokyo", theme: "sy", cookie: cookie)
    Current.preference = pref
    h = Current.preference.to_h

    assert_equal "ja", h[:language]
    assert_equal "jp", h[:region]
    assert_equal "Asia/Tokyo", h[:timezone]
    assert_equal "sy", h[:theme]
    assert h[:consented]
  ensure
    Current.reset
  end

  test "preference with_cookie returns new preference" do
    Current.reset
    pref = Current::Preference.new(language: "ja", region: "jp")
    new_cookie = Current::Preference::Cookie.new(
      consented: true, functional: true, performant: true, targetable: true,
      consent_version: "2", consented_at: Time.current,
    )
    result = pref.with_cookie(new_cookie)

    assert_predicate result.cookie, :consented?
    assert_predicate result.cookie, :functional?
    assert_equal "ja", result.language
    assert_equal "jp", result.region
  ensure
    Current.reset
  end

  test "Preference.from_jwt returns NULL for nil claim" do
    assert_predicate Current::Preference.from_jwt(nil), :null?
  end

  test "Preference.from_jwt returns NULL for non-hash claim" do
    assert_predicate Current::Preference.from_jwt("string"), :null?
  end

  test "Preference.from_jwt builds preference from hash" do
    pref = Current::Preference.from_jwt({ "lx" => "en", "ri" => "us", "tz" => "America/Chicago", "ct" => "li" })

    assert_equal "en", pref.language
    assert_equal "us", pref.region
    assert_equal "America/Chicago", pref.timezone
    assert_equal "li", pref.theme
  end

  test "Preference.from_jwt uses defaults for missing keys" do
    pref = Current::Preference.from_jwt({})

    assert_equal "ja", pref.language
    assert_equal "jp", pref.region
    assert_equal "Asia/Tokyo", pref.timezone
    assert_equal "sy", pref.theme
  end

  test "Preference.cookie_from passes through Cookie instance" do
    cookie = Current::Preference::Cookie.new(
      consented: true, functional: false, performant: false, targetable: false,
      consent_version: nil, consented_at: nil,
    )
    result = Current::Preference.cookie_from(cookie)

    assert_same cookie, result
  end

  test "Preference.cookie_from builds from Hash with symbol keys" do
    result = Current::Preference.cookie_from(
      { consented: true,
        functional: true,
        performant: false,
        targetable: false,
        consent_version: "1",
        consented_at: Time.current, },
    )

    assert_predicate result, :consented?
    assert_predicate result, :functional?
  end

  test "Preference.cookie_from builds from Hash with string keys" do
    result = Current::Preference.cookie_from(
      { "consented" => true,
        "functional" => true,
        "performant" => false,
        "targetable" => false,
        "consent_version" => "1",
        "consented_at" => Time.current, },
    )

    assert_predicate result, :consented?
    assert_predicate result, :functional?
  end

  test "Preference.cookie_from returns NULL_COOKIE for blank value" do
    result = Current::Preference.cookie_from(nil)

    assert_not_predicate result, :consented?
  end

  test "Preference.cookie_from builds from object" do
    obj = Struct.new(:consented, :functional, :performant, :targetable, :consent_version, :consented_at).new(
      true,
      false, false, false, "1", Time.current,
    )
    result = Current::Preference.cookie_from(obj)

    assert_predicate result, :consented?
    assert_not_predicate result, :functional?
  end
end
