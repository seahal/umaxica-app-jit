# typed: false
# frozen_string_literal: true

require "test_helper"

class News::Org::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV.fetch("NEWS_STAFF_URL", "news.org.localhost")
  end

  test "returns client_id as news_org" do
    controller = News::Org::Auth::CallbacksController.new

    assert_equal "news_org", controller.send(:oidc_client_id)
  end

  test "callback route exists" do
    assert_routing(
      { method: :get, path: "http://#{@host}/auth/callback" },
      { host: @host, controller: "news/org/auth/callbacks", action: "show" },
    )
  end
end
