# typed: false
# frozen_string_literal: true

require "test_helper"

class News::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("NEWS_CORPORATE_URL", "news.com.localhost")
  end

  test "returns client_id as news_com" do
    controller = News::Com::Auth::CallbacksController.new

    assert_equal "news_com", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "news/com/auth/callbacks", action: "show" },
    )
  end
end
