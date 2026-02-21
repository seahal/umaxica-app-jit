# frozen_string_literal: true

require "test_helper"

class Sign::Org::RecoveriesControllerTest < ActionDispatch::IntegrationTest
  test "controller has new action" do
    controller = Sign::Org::RecoveriesController.new
    assert_respond_to controller, :new
  end

  test "controller has create action" do
    controller = Sign::Org::RecoveriesController.new
    assert_respond_to controller, :create
  end

  test "controller has reject_logged_in_session before_action" do
    before_actions = Sign::Org::RecoveriesController._process_action_callbacks
      .select { |cb| cb.kind == :before }
      .map { |cb| cb.filter }
    assert_includes before_actions, :reject_logged_in_session
  end

  test "controller defines RecoveryForm" do
    form_class = Sign::Org::RecoveriesController::RecoveryForm
    assert defined?(form_class)
  end

  test "RecoveryForm has account_identifiable_information attribute" do
    form = Sign::Org::RecoveriesController::RecoveryForm.new
    assert_respond_to form, :account_identifiable_information
    assert_respond_to form, :account_identifiable_information=
  end

  test "RecoveryForm has recovery_code attribute" do
    form = Sign::Org::RecoveriesController::RecoveryForm.new
    assert_respond_to form, :recovery_code
    assert_respond_to form, :recovery_code=
  end

  test "RecoveryForm includes ActiveModel::Model" do
    form = Sign::Org::RecoveriesController::RecoveryForm.new
    assert_kind_of ActiveModel::Model, form
  end
end
