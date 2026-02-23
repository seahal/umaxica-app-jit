# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::In::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
  end

  test "controller has new action" do
    controller = Sign::App::In::RecoveriesController.new
    assert_respond_to controller, :new
  end

  test "controller has create action" do
    controller = Sign::App::In::RecoveriesController.new
    assert_respond_to controller, :create
  end

  test "controller defines RecoveryForm" do
    form_class = Sign::App::In::RecoveriesController::RecoveryForm
    assert defined?(form_class)
  end

  test "RecoveryForm has account_identifiable_information attribute" do
    form = Sign::App::In::RecoveriesController::RecoveryForm.new
    assert_respond_to form, :account_identifiable_information
    assert_respond_to form, :account_identifiable_information=
  end

  test "RecoveryForm has recovery_code attribute" do
    form = Sign::App::In::RecoveriesController::RecoveryForm.new
    assert_respond_to form, :recovery_code
    assert_respond_to form, :recovery_code=
  end

  test "RecoveryForm includes ActiveModel::Model" do
    form = Sign::App::In::RecoveriesController::RecoveryForm.new
    assert_kind_of ActiveModel::Model, form
  end
end
