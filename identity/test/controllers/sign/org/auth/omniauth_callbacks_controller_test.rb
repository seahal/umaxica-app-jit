# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Auth::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_statuses, :staff_email_statuses, :staff_visibilities, :staff_tokens,
           :staff_token_kinds, :staff_token_statuses

  GOOGLE_PROVIDER = "google_org"

  setup do
    host! ENV.fetch("IDENTITY_SIGN_ORG_URL", "sign.org.localhost")
    OmniAuth.config.test_mode = true

    @staff = staffs(:one)
    @staff.update!(status_id: StaffStatus::ACTIVE)
    StaffToken.where(staff_id: @staff.id).delete_all
    @staff_email = StaffEmail.create!(
      staff: @staff,
      address: "google_staff@example.com",
      staff_email_status_id: StaffEmailStatus::VERIFIED,
    )

    set_mock_google_auth(email: @staff_email.address)
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(GOOGLE_PROVIDER.to_sym)
  end

  # --- Successful sign-in ---

  test "omniauth redirects to destination on successful staff sign-in" do
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_nil flash[:alert], "Unexpected alert: #{flash[:alert]}"
    assert_redirected_to sign_org_root_path(ri: "jp")
    assert_not_nil flash[:notice]
    assert_includes flash[:notice], "Google"
  end

  test "omniauth marks the matched staff email as oauth_linked" do
    assert_not_equal StaffEmailStatus::OAUTH_LINKED, @staff_email.staff_identity_email_status_id
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_equal StaffEmailStatus::OAUTH_LINKED, @staff_email.reload.staff_identity_email_status_id
  end

  # --- Staff not found ---

  test "omniauth redirects to sign-in with error when no staff has that email" do
    set_mock_google_auth(email: "unknown@example.com")
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_redirected_to new_sign_org_in_path(ri: "jp")
    assert_equal I18n.t("sign.org.social.sessions.create.not_found"), flash[:alert]
  end

  test "omniauth redirects to sign-in with error when staff is not active" do
    @staff.update!(status_id: StaffStatus::NOTHING)
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_redirected_to new_sign_org_in_path(ri: "jp")
    assert_equal I18n.t("sign.org.social.sessions.create.not_found"), flash[:alert]
  end

  test "omniauth redirects to sign-in with failure when staff is withdrawn" do
    @staff.update!(status_id: StaffStatus::ACTIVE, withdrawn_at: Time.current)
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_redirected_to new_sign_org_in_path(ri: "jp")
    assert_equal I18n.t("sign.org.social.sessions.create.failure"), flash[:alert]
  end

  # --- Failure callback ---

  test "failure redirects to sign-in with error" do
    get sign_org_auth_failure_path(message: "access_denied", strategy: GOOGLE_PROVIDER, ri: "jp")

    assert_redirected_to new_sign_org_in_path(ri: "jp")
    assert_equal I18n.t("sign.org.social.sessions.create.failure"), flash[:alert]
  end

  # --- Session limit ---

  test "omniauth redirects to session management when one logical staff session has many rotated ancestors" do
    create_rotated_active_staff_session(@staff, rotations: 4)
    state = initiate_social_auth_flow!

    get sign_org_auth_callback_path(provider: GOOGLE_PROVIDER, ri: "jp", state: state)

    assert_redirected_to sign_org_in_session_path(ri: "jp")
    assert_equal "セッション数が上限に達しています。既存セッションを管理してください。", flash[:notice]
    assert_equal 1, StaffToken.where(staff_id: @staff.id, status: StaffToken::STATUS_RESTRICTED).count
  end

  private

  # Initiates the social auth flow via /social/session/new, which sets session state,
  # then follows the redirect through OmniAuth request phase.
  # Returns the state parameter for use in callback requests.
  def initiate_social_auth_flow!
    get(new_sign_org_social_session_path(provider: GOOGLE_PROVIDER, ri: "jp"))

    assert_response :redirect

    # Extract state from redirect URL to /auth/google_org?state=...
    # Session state is already set by prepare_social_auth_intent! in the controller
    redirect_uri = URI.parse(response.location)
    Rack::Utils.parse_query(redirect_uri.query)["state"]
  end

  def set_mock_google_auth(email:)
    OmniAuth.config.mock_auth[GOOGLE_PROVIDER.to_sym] = OmniAuth::AuthHash.new(
      provider: GOOGLE_PROVIDER,
      uid: "google_uid_#{SecureRandom.hex(8)}",
      info: {
        email: email,
        name: "Test Staff",
      },
      credentials: {
        token: "mock_token",
        refresh_token: "mock_refresh_token",
        expires_at: 1.hour.from_now.to_i,
      },
    )
  end

  def create_rotated_active_staff_session(staff, rotations:)
    token = StaffToken.create!(staff: staff, status: StaffToken::STATUS_ACTIVE)
    refresh = token.rotate_refresh_token!

    rotations.times do
      refresh = Sign::RefreshTokenService.call(refresh_token: refresh)[:refresh_token]
    end
  end
end
