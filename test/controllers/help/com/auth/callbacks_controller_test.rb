# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as help_com" do
    controller = Help::Com::Auth::CallbacksController.new

    assert_equal "help_com", controller.send(:oidc_client_id)
  end
end
