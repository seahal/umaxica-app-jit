# frozen_string_literal: true

require "test_helper"

class Sign::App::In::TotpsControllerTest < ActionDispatch::IntegrationTest
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
    before_actions = Sign::App::In::TotpsController._process_action_callbacks
      .select { |cb| cb.kind == :before }
      .map { |cb| cb.filter }
    assert_includes before_actions, :ensure_mfa_user!
  end

  test "controller has reject_logged_in_session before_action" do
    before_actions = Sign::App::In::TotpsController._process_action_callbacks
      .select { |cb| cb.kind == :before }
      .map { |cb| cb.filter }
    assert_includes before_actions, :reject_logged_in_session
  end
end
