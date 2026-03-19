# typed: false
# frozen_string_literal: true

require "test_helper"

class News::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as news_org" do
    controller = News::Org::Auth::CallbacksController.new

    assert_equal "news_org", controller.send(:oidc_client_id)
  end
end
