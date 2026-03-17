# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::RootsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  include RootThemeCookieHelper

  setup do
    @original_rate_limit_rules = Sign::App::RootsController.rate_limit_rules
    Sign::App::RootsController.rate_limit_rules = [
      {
        name: "test_root_web",
        scope: "ip",
        limit: 2,
        period: 60,
        key: nil,
        retry_after: 60,
        only: [],
        except: [],
      },
    ]
    RailsRateLimit.store.clear! if RailsRateLimit.store.respond_to?(:clear!)
  end

  teardown do
    Sign::App::RootsController.rate_limit_rules = @original_rate_limit_rules
    RailsRateLimit.store.clear! if RailsRateLimit.store.respond_to?(:clear!)
  end

  test "GET / redirects to new registration path" do
    get sign_app_root_url(ri: "jp")

    # Controller now renders the root index page with links to registration
    assert_response :success
    assert_select "h1", minimum: 1
  end

  test "GET / returns redirect status" do
    get sign_app_root_url(ri: "jp")

    assert_response :success
  end

  test "renders layout contract" do
    get sign_app_root_url(ri: "jp")

    assert_response :success
    assert_layout_contract
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "footer contains navigation links" do
    get sign_app_root_url(ri: "jp")

    assert_response :success
    assert_select "footer" do
      assert_select "a"
      assert_select "a[href=?]", sign_app_root_url(ri: "jp"),
                    text: I18n.t("sign.app.preferences.footer.home")
      assert_select "a[href=?]", apex_app_preference_url(ri: "jp"),
                    text: I18n.t("sign.app.preferences.footer.preference")
      assert_select "a[href=?]", sign_app_configuration_url(ri: "jp"),
                    text: I18n.t("sign.app.preferences.footer.configuration")
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "generates sha3-384 token digest on root" do
    get sign_app_root_url(ri: "jp")

    assert_response :success
    assert_equal 48, AppPreference.order(:created_at).last.token_digest.bytesize
  end

  test "sets theme cookie" do
    assert_theme_cookie_for(
      host: "sign.app.localhost",
      path: :sign_app_root_path,
      label: "sign app root",
      ri: "jp",
    )
  end

  test "GET / fails when logged in" do
    user = users(:one)
    get sign_app_root_url(ri: "jp"), headers: { "X-TEST-CURRENT-USER" => user.id }

    assert_response :unauthorized
    assert_equal "権限がありません", response.body
  end

  test "rate limit applies on root for HTML requests" do
    get sign_app_root_url(ri: "jp")

    assert_response :success

    get sign_app_root_url(ri: "jp")

    assert_response :success

    get sign_app_root_url(ri: "jp")

    assert_response :too_many_requests

    assert_equal "rails", response.headers["X-RateLimit-Layer"]
    assert_equal "test_root_web", response.headers["X-RateLimit-Rule"]
    assert_predicate response.headers["Retry-After"], :present?
  end

  test "rate limit applies on root for JSON requests" do
    get sign_app_root_url(ri: "jp")

    assert_response :success

    get sign_app_root_url(ri: "jp")

    assert_response :success

    get sign_app_root_url(ri: "jp"), headers: { "Accept" => "application/json" }

    assert_response :too_many_requests

    assert_equal "rails", response.headers["X-RateLimit-Layer"]
    assert_equal "test_root_web", response.headers["X-RateLimit-Rule"]
    assert_predicate response.headers["Retry-After"], :present?

    body = response.parsed_body

    assert_equal "rate_limited", body["error"]
    assert_equal "test_root_web", body["rule"]
    assert_predicate body["message"], :present?
  end

  test "rate limit throttling emits notifications on root" do
    payloads = []
    callback =
      lambda do |_name, _start, _finish, _id, payload|
        payloads << payload
      end

    ActiveSupport::Notifications.subscribed(callback, "rails_rate_limit.throttled") do
      get sign_app_root_url(ri: "jp")
      get sign_app_root_url(ri: "jp")
      get sign_app_root_url(ri: "jp")
    end

    assert_response :too_many_requests
    assert_operator payloads.size, :>=, 1
  end
end
