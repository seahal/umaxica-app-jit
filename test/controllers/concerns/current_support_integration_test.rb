# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentSupportDummyControllerBase < ApplicationController
  include CurrentSupport

  before_action :set_current
  after_action :_reset_current_state

  def show
    render json: {
      actor_class: Current.actor.class.name,
      actor_public_id: Current.actor.respond_to?(:public_id) ? Current.actor.public_id : nil,
      actor_type: Current.actor_type.to_s,
      domain: Current.domain.to_s,
      surface: Current.surface.to_s,
      realm: Current.realm.to_s,
      request_id: Current.request_id,
      session: Current.session,
      token: Current.token,
      preference: {
        language: Current.preference.language,
        region: Current.preference.region,
        timezone: Current.preference.timezone,
        theme: Current.preference.theme,
        null: Current.preference.null?,
        cookie: {
          consented: Current.preference.cookie.consented?,
          functional: Current.preference.cookie.functional?,
          performant: Current.preference.cookie.performant?,
          targetable: Current.preference.cookie.targetable?,
          consent_version: Current.preference.cookie.consent_version,
        },
      },
    }
  end

  private

  def current_resource
    actor_id = request.headers["X-TEST-ACTOR-ID"]
    return if actor_id.blank?

    case request.headers["X-TEST-ACTOR-CLASS"]
    when "User"
      User.find(actor_id)
    when "Staff"
      Staff.find(actor_id)
    when "Customer"
      Customer.find(actor_id)
    end
  end

  def access_token_payload
    parse_test_json_header("X-TEST-ACCESS-TOKEN-PAYLOAD")
  end

  def load_access_token_payload
    parse_test_json_header("X-TEST-LOAD-ACCESS-TOKEN-PAYLOAD")
  end

  def preference_payload_preferences
    parse_test_json_header("X-TEST-PREFERENCE-PAYLOAD-PREFERENCES")
  end

  def parse_test_json_header(name)
    raw_value = request.headers[name]
    return if raw_value.blank?
    raise RuntimeError, "forced header parse error" if raw_value == "raise"

    JSON.parse(raw_value)
  end
end

module Sign
  module App
    class CurrentSupportDummyController < ::CurrentSupportDummyControllerBase
    end
  end
end

module Apex
  module App
    class CurrentSupportDummyController < ::CurrentSupportDummyControllerBase
    end
  end
end

module Core
  module App
    class CurrentSupportDummyController < ::CurrentSupportDummyControllerBase
    end
  end
end

class CurrentSupportIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  test "sign request resolves DB-backed preference and resets Current after response" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)
    preference = UserPreference.create!(
      user: user,
      language: "en",
      region: "us",
      timezone: "Etc/UTC",
      theme: "dr",
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
      consent_version: SecureRandom.uuid,
      consented_at: Time.current,
    )

    with_test_routes do
      get "/sign/current_support",
          headers: {
            "Host" => "sign.app.localhost",
            "X-TEST-ACTOR-CLASS" => "User",
            "X-TEST-ACTOR-ID" => user.id.to_s,
          }
    end

    assert_response :success

    body = JSON.parse(@response.body)

    assert_current_snapshot(
      body,
      actor_class: "User",
      actor_public_id: user.public_id,
      actor_type: "user",
      domain: "app",
      surface: "app",
      realm: "sign",
      session: nil,
      language: preference.language,
      region: preference.region,
      timezone: preference.timezone,
      theme: preference.theme,
      null_preference: false,
      consented: true,
      functional: true,
      performant: true,
      targetable: false,
      consent_version: preference.consent_version,
    )
    assert_current_reset
  end

  test "apex request falls back to JWT preference payload and resets Current after response" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: UserStatus::NOTHING)

    with_test_routes do
      get "/apex/current_support",
          headers: {
            "Host" => "app.localhost",
            "X-TEST-ACTOR-CLASS" => "User",
            "X-TEST-ACTOR-ID" => user.id.to_s,
            "X-TEST-ACCESS-TOKEN-PAYLOAD" => {
              sid: "session-from-access-token",
              prf: { lx: "en", ri: "us", tz: "Etc/UTC", ct: "li" },
            }.to_json,
            "X-TEST-PREFERENCE-PAYLOAD-PREFERENCES" => {
              consented: true,
              functional: true,
              performant: false,
              targetable: true,
              consent_version: "jwt-cookie-version",
            }.to_json,
          }
    end

    assert_response :success

    body = JSON.parse(@response.body)

    assert_current_snapshot(
      body,
      actor_type: "user",
      domain: "app",
      surface: "app",
      realm: "apex",
      session: "session-from-access-token",
      language: "en",
      region: "us",
      timezone: "Etc/UTC",
      theme: "li",
      null_preference: false,
      consented: true,
      functional: true,
      performant: false,
      targetable: true,
      consent_version: "jwt-cookie-version",
    )
    assert_equal "session-from-access-token", body.dig("token", "sid")
    assert_current_reset
  end

  test "core request falls back to null preference and load_access_token_payload for unauthenticated actor" do
    with_test_routes do
      get "/core/current_support",
          headers: {
            "Host" => "www.app.localhost",
            "X-TEST-LOAD-ACCESS-TOKEN-PAYLOAD" => { sid: "session-from-loader" }.to_json,
            "X-TEST-PREFERENCE-PAYLOAD-PREFERENCES" => {
              consented: false,
              functional: true,
              performant: false,
              targetable: false,
              consent_version: "loader-cookie-version",
            }.to_json,
          }
    end

    assert_response :success

    body = JSON.parse(@response.body)

    assert_current_snapshot(
      body,
      actor_class: "Module",
      actor_public_id: nil,
      actor_type: "unauthenticated",
      domain: "app",
      surface: "app",
      realm: "core",
      session: "session-from-loader",
      language: "ja",
      region: "jp",
      timezone: "Asia/Tokyo",
      theme: "sy",
      null_preference: true,
      consented: false,
      functional: true,
      performant: false,
      targetable: false,
      consent_version: "loader-cookie-version",
    )
    assert_current_reset
  end

  private

  def assert_current_snapshot(
    body,
    actor_class: body["actor_class"],
    actor_public_id: body["actor_public_id"],
    actor_type:,
    domain:,
    surface:,
    realm:,
    session:,
    language:,
    region:,
    timezone:,
    theme:,
    null_preference:,
    consented:,
    functional:,
    performant:,
    targetable:,
    consent_version:
  )
    assert_equal actor_class, body["actor_class"]
    if actor_public_id.nil?
      assert_nil body["actor_public_id"]
    else
      assert_equal actor_public_id, body["actor_public_id"]
    end

    assert_equal actor_type, body["actor_type"]
    assert_equal domain, body["domain"]
    assert_equal surface, body["surface"]
    assert_equal realm, body["realm"]
    if session.nil?
      assert_nil body["session"]
    else
      assert_equal session, body["session"]
    end

    assert_equal language, body.dig("preference", "language")
    assert_equal region, body.dig("preference", "region")
    assert_equal timezone, body.dig("preference", "timezone")
    assert_equal theme, body.dig("preference", "theme")
    assert_equal null_preference, body.dig("preference", "null")
    assert_equal consented, body.dig("preference", "cookie", "consented")
    assert_equal functional, body.dig("preference", "cookie", "functional")
    assert_equal performant, body.dig("preference", "cookie", "performant")
    assert_equal targetable, body.dig("preference", "cookie", "targetable")
    assert_equal consent_version, body.dig("preference", "cookie", "consent_version")
  end

  def assert_current_reset
    assert_same Unauthenticated.instance, Current.actor
    assert_equal :unauthenticated, Current.actor_type
    assert_nil Current.session
    assert_nil Current.token
    assert_predicate Current.preference, :null?
  end

  def with_test_routes
    with_routing do |set|
      set.draw do
        get("/sign/current_support", to: "sign/app/current_support_dummy#show")
        get("/apex/current_support", to: "apex/app/current_support_dummy#show")
        get("/core/current_support", to: "core/app/current_support_dummy#show")
      end

      yield
    end
  end
end
