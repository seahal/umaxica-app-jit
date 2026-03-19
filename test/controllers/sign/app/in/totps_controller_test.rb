# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::In::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_email_statuses, :user_secret_kinds, :user_secret_statuses,
           :user_one_time_password_statuses

  setup do
    @controller = Sign::App::In::TotpsController.new
    @user = User.create!(status_id: UserStatus::ACTIVE)
    @user.user_emails.create!(
      address: "totps-controller-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )
  end

  test "controller defines MFA_USER_SESSION_KEY constant" do
    assert_equal :mfa_user_id, Sign::App::In::TotpsController::MFA_USER_SESSION_KEY
  end

  test "TotpChallengeForm validates token presence" do
    form = Sign::App::In::TotpsController::TotpChallengeForm.new
    form.token = nil

    assert_not form.valid?
    assert_predicate form.errors[:token], :any?
  end

  test "TotpChallengeForm validates token length" do
    form = Sign::App::In::TotpsController::TotpChallengeForm.new
    form.token = "123"

    assert_not form.valid?
    assert_predicate form.errors[:token], :any?
  end

  test "TotpChallengeForm accepts valid 6-digit token" do
    form = Sign::App::In::TotpsController::TotpChallengeForm.new
    form.token = "123456"

    assert_predicate form, :valid?
  end

  test "TotpChallengeForm has model_name for form builders" do
    model_name = Sign::App::In::TotpsController::TotpChallengeForm.model_name

    assert_equal "totp_challenge_form", model_name.param_key
  end

  test "controller includes Common::Redirect" do
    assert_includes Sign::App::In::TotpsController, Common::Redirect
  end

  test "controller includes SessionLimitGate" do
    assert_includes Sign::App::In::TotpsController, SessionLimitGate
  end

  test "controller has new action" do
    assert_includes Sign::App::In::TotpsController.instance_methods, :new
  end

  test "controller has create action" do
    assert_includes Sign::App::In::TotpsController.instance_methods, :create
  end

  test "controller has ensure_mfa_user before_action" do
    before_actions =
      Sign::App::In::TotpsController._process_action_callbacks
        .select { |cb| cb.kind == :before }
        .map { |cb| cb.filter }

    assert_includes before_actions, :ensure_mfa_user!
  end

  test "controller has reject_logged_in_session before_action" do
    before_actions =
      Sign::App::In::TotpsController._process_action_callbacks
        .select { |cb| cb.kind == :before }
        .map { |cb| cb.filter }

    assert_includes before_actions, :reject_logged_in_session
  end

  test "TotpChallengeForm validates token is digits only" do
    form = Sign::App::In::TotpsController::TotpChallengeForm.new
    form.token = "abcdef"

    assert_not form.valid?
  end

  test "verify_totp_for returns matching active totp record" do
    UserOneTimePassword.create!(
      user: @user,
      private_key: "JBSWY3DPEHPK3PXP",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
      title: "old totp",
    )
    matching_totp = UserOneTimePassword.create!(
      user: @user,
      private_key: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
      title: "new totp",
    )
    code = ROTP::TOTP.new(matching_totp.private_key).at(Time.current.to_i)

    last_otp_at, record = @controller.send(:verify_totp_for, @user, code)

    assert_equal matching_totp, record
    assert_kind_of Integer, last_otp_at
  end

  test "verify_totp_for returns nils when token does not match any active totp" do
    UserOneTimePassword.create!(
      user: @user,
      private_key: "JBSWY3DPEHPK3PXP",
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      last_otp_at: Time.zone.at(0),
      title: "only totp",
    )

    last_otp_at, record = @controller.send(:verify_totp_for, @user, "000000")

    assert_nil last_otp_at
    assert_nil record
  end

  test "active_secret_hints_for returns four-character hints for active secrets" do
    UserSecret.issue!(
      name: "ABCD-secret",
      user_id: @user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )
    travel 1.second do
      UserSecret.issue!(
        name: "EFGH-secret",
        user_id: @user.id,
        user_secret_kind_id: UserSecretKind::PERMANENT,
        uses: 10,
        status: :active,
      )
    end

    assert_equal %w(EFGH ABCD), @controller.send(:active_secret_hints_for, @user)
  end
end
