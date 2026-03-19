# typed: false
# frozen_string_literal: true

require "test_helper"

class News::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as news_app" do
    controller = News::App::Auth::CallbacksController.new

    assert_equal "news_app", controller.send(:oidc_client_id)
  end
end
