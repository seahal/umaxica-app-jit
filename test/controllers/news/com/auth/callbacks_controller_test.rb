# typed: false
# frozen_string_literal: true

require "test_helper"

class News::Com::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
  test "returns client_id as news_com" do
    controller = News::Com::Auth::CallbacksController.new

    assert_equal "news_com", controller.send(:oidc_client_id)
  end
end
