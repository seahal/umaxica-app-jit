# typed: false
# frozen_string_literal: true

require "test_helper"

class Help::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as help_org" do
    controller = Help::Org::Auth::CallbacksController.new

    assert_equal "help_org", controller.send(:oidc_client_id)
  end
end
