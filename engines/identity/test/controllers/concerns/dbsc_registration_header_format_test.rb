# typed: false
# frozen_string_literal: true

require "test_helper"

class DbscRegistrationHeaderFormatTest < ActiveSupport::TestCase
  fixtures :users

  test "authentication dbsc registration header uses structured-field tokens" do
    token = UserToken.create!(
      user: users(:one),
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_binding_method_id: UserTokenBindingMethod::NOTHING,
      user_token_dbsc_status_id: UserTokenDbscStatus::NOTHING,
      refresh_expires_at: 1.day.from_now,
      deletable_at: 1.day.from_now,
    )

    controller = Jit::Identity::Sign::App::Edge::V0::Token::ChecksController.new
    controller.instance_variable_set(:@_response, ActionDispatch::Response.new)
    controller.define_singleton_method(:token_dbsc_path) { "/edge/v0/token/dbsc" }

    controller.send(:issue_dbsc_registration_header_for, token)

    registration_header = controller.response.headers[Auth::IoKeys::Headers::DBSC_REGISTRATION]

    assert_predicate registration_header, :present?
    assert_includes registration_header, "(ES256 RS256);"
    assert_not_includes registration_header, '"ES256"'
    assert_not_includes registration_header, '"RS256"'
  end

  test "preference dbsc registration header uses structured-field tokens" do
    preference = AppPreference.create!(status_id: AppPreferenceStatus::NOTHING)

    controller = Jit::Zenith::Acme::App::Edge::V0::CookiesController.new
    controller.instance_variable_set(:@_response, ActionDispatch::Response.new)
    controller.define_singleton_method(:preference_dbsc_path) { "/edge/v0/dbsc" }

    controller.send(:issue_preference_dbsc_registration_header_for, preference)

    registration_header = controller.response.headers[Preference::IoKeys::Headers::DBSC_REGISTRATION]

    assert_predicate registration_header, :present?
    assert_includes registration_header, "(ES256 RS256);"
    assert_not_includes registration_header, '"ES256"'
    assert_not_includes registration_header, '"RS256"'
  end

  test "authentication dbsc cookie value does not fall back to public id" do
    token = UserToken.create!(
      user: users(:one),
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_binding_method_id: UserTokenBindingMethod::DBSC,
      user_token_dbsc_status_id: UserTokenDbscStatus::ACTIVE,
      refresh_expires_at: 1.day.from_now,
      deletable_at: 1.day.from_now,
      public_id: "public-session-id",
      dbsc_session_id: nil,
    )

    controller = Jit::Identity::Sign::App::Edge::V0::Token::ChecksController.new

    assert_nil controller.send(:dbsc_cookie_value_for, token)
  end
end
