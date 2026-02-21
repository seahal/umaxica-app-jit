# frozen_string_literal: true

require "test_helper"

class Sign::Org::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs

  setup do
    @host = ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost")
    @staff = staffs(:one)
  end

  test "controller has new action" do
    controller = Sign::Org::PasskeysController.new
    assert_respond_to controller, :new
  end

  test "controller has edit action" do
    controller = Sign::Org::PasskeysController.new
    assert_respond_to controller, :edit
  end

  test "controller has create action" do
    controller = Sign::Org::PasskeysController.new
    assert_respond_to controller, :create
  end

  test "controller has update action" do
    controller = Sign::Org::PasskeysController.new
    assert_respond_to controller, :update
  end

  test "controller has reject_logged_in_session before_action" do
    before_actions = Sign::Org::PasskeysController._process_action_callbacks
      .select { |cb| cb.kind == :before }
      .map { |cb| cb.filter }
    assert_includes before_actions, :reject_logged_in_session
  end

  test "new assigns StaffTelephone" do
    controller = Sign::Org::PasskeysController.new
    controller.instance_variable_set(:@staff_telephone, StaffTelephone.new)
    assert_not_nil controller.instance_variable_get(:@staff_telephone)
  end
end
