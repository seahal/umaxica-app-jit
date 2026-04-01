# typed: false
# frozen_string_literal: true

require "test_helper"

class News::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("NEWS_SERVICE_URL", "news.app.localhost")
  end

  test "returns client_id as news_app" do
    controller = News::App::Auth::CallbacksController.new

    assert_equal "news_app", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "news/app/auth/callbacks", action: "show" },
    )
  end
end
