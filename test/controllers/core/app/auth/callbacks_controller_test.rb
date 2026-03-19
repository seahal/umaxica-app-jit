# typed: false
# frozen_string_literal: true

require "test_helper"

class Core::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as core_app" do
    controller = Core::App::Auth::CallbacksController.new

    assert_equal "core_app", controller.send(:oidc_client_id)
  end
end
