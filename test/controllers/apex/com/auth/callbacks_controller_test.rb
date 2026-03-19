# typed: false
# frozen_string_literal: true

require "test_helper"

class Apex::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as apex_com" do
    controller = Apex::Com::Auth::CallbacksController.new

    assert_equal "apex_com", controller.send(:oidc_client_id)
  end
end
