# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as help_app" do
    controller = Help::App::Auth::CallbacksController.new

    assert_equal "help_app", controller.send(:oidc_client_id)
  end
end
