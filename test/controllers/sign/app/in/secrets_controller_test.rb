# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SecretsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_secret_kinds, :user_secret_statuses, :user_email_statuses,
           :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @raw_email = "secret_login_#{SecureRandom.hex(4)}@example.com".freeze
    @email = @user.user_emails.create!(address: @raw_email, user_email_status_id: UserEmailStatus::VERIFIED)
    @telephone = @user.user_telephones.create!(number: "+819012345678")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should get new" do
    get new_sign_app_in_secret_url(ri: "jp"), headers: default_headers
    assert_response :success
  end

  test "should return unprocessable_content with invalid params" do
    post sign_app_in_secret_url(ri: "jp"),
         params: { secret_login_form: { identifier: "", secret_value: "" } },
         headers: default_headers
    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "identifier without @ or + is rejected" do
    _secret, raw_secret = issue_secret!

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: "plaintext", secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "turnstile failure returns unified authentication error" do
    CloudflareTurnstile.test_validation_response = { "success" => false }
    _secret, raw_secret = issue_secret!

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "email and matching permanent secret logs in successfully" do
    _secret, raw_secret = issue_secret!(kind: UserSecretKind::PERMANENT, uses: 10)

    get new_sign_app_in_secret_url(ri: "jp"), headers: default_headers
    old_session_id = session.id

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email.upcase, secret_value: raw_secret),
         headers: default_headers

    assert_response :found
    assert_redirected_to "/?ri=jp"
    assert_not_equal old_session_id, session.id
  end

  test "telephone and matching permanent secret logs in successfully" do
    _secret, raw_secret = issue_secret!(kind: UserSecretKind::PERMANENT, uses: 10)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: "+819012345678", secret_value: raw_secret),
         headers: default_headers

    assert_response :found
    assert_redirected_to "/?ri=jp"
  end

  test "mismatched secret fails with unified message" do
    _secret, _raw_secret = issue_secret!

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: "wrong-secret"),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "unknown user fails with unified message" do
    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: "missing-#{SecureRandom.hex(4)}@example.com", secret_value: "nope"),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "known user with no secret fails with unified message" do
    @user.user_secrets.delete_all

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: "nope"),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "one-time secret decrements uses and cannot be reused once exhausted" do
    one_time_secret, raw_secret = issue_secret!(kind: UserSecretKind::ONE_TIME, uses: 1)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :found
    assert_redirected_to "/?ri=jp"
    assert_equal 0, one_time_secret.reload.uses_remaining
    assert_equal UserSecretStatus::USED, one_time_secret.user_secret_status_id

    reset!
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "expired secret fails authentication" do
    _secret, raw_secret = issue_secret!(expires_at: 1.minute.ago)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "one-time secret with uses_remaining 0 fails authentication" do
    secret, raw_secret = issue_secret!(kind: UserSecretKind::ONE_TIME, uses: 1)
    secret.update!(uses_remaining: 0)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "secret with disallowed status fails authentication" do
    _secret, raw_secret = issue_secret!(status: :revoked)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "secret with disallowed kind fails authentication" do
    _secret, raw_secret = issue_secret!(kind: UserSecretKind::TOTP, uses: 10)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :unprocessable_entity
    assert_includes response.body, I18n.t("sign.app.authentication.secret.create.invalid")
  end

  test "secret login succeeds without extra confirmation parameter" do
    _secret, raw_secret = issue_secret!

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :found
    assert_redirected_to "/?ri=jp"
    assert_not_nil session.id
  end

  test "guest request does not query users with null mfa_user_id" do
    queries =
      capture_sql_queries do
        get new_sign_app_in_secret_url(ri: "jp"), headers: default_headers
      end

    assert_response :success
    assert_not queries.any? { |sql| sql.match?(/FROM "users".*"users"."id" IS NULL/i) },
               "expected no users.id IS NULL query, got: #{queries.grep(/users/i).join("\n")}"
  end

  private

  def issue_secret!(kind: UserSecretKind::PERMANENT, uses: 1, expires_at: nil, status: :active)
    UserSecret.issue!(
      name: "Secret-#{SecureRandom.hex(4)}",
      user_id: @user.id,
      user_secret_kind_id: kind,
      uses: uses,
      expires_at: expires_at,
      status: status,
    )
  end

  def login_params(identifier:, secret_value:)
    {
      secret_login_form: {
        identifier: identifier,
        secret_value: secret_value,
      },
      "cf-turnstile-response": "test_token",
    }
  end

  def default_headers
    { "Host" => ENV["SIGN_SERVICE_URL"] || "sign.app.localhost" }
  end

  def capture_sql_queries
    queries = []
    callback =
      lambda do |_name, _started, _finished, _id, payload|
        sql = payload[:sql].to_s
        next if sql.blank?
        next if payload[:name].to_s == "SCHEMA"
        next if payload[:cached]

        queries << sql
      end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end
    queries
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "secret login with session limit exceeded redirects to session management" do
    UserToken.where(user_id: @user.id).delete_all

    # Create 2 active sessions to hit the limit
    2.times do
      token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
      token.rotate_refresh_token!
    end

    _secret, raw_secret = issue_secret!(kind: UserSecretKind::PERMANENT, uses: 10)

    post sign_app_in_secret_url(ri: "jp"),
         params: login_params(identifier: @raw_email, secret_value: raw_secret),
         headers: default_headers

    assert_response :found
    assert_redirected_to sign_app_in_session_path
    assert_equal I18n.t("sign.app.in.session.restricted_notice"), flash[:notice]

    # A restricted token should have been created
    restricted = UserToken.where(user_id: @user.id, status: UserToken::STATUS_RESTRICTED)
    assert_equal 1, restricted.count

    # Session limit gate should be issued
    assert_predicate session[SessionLimitGate::GATE_SESSION_KEY], :present?
  end
  # rubocop:enable Minitest/MultipleAssertions
end
