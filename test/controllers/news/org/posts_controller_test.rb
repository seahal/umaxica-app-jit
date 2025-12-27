# frozen_string_literal: true

require "test_helper"

module News
  module Org
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("NEWS_STAFF_URL", "news.org.localhost")
      end

      test "should get index" do
        get news_org_posts_url
        assert_response :success
      end

      test "should get show" do
        get news_org_post_url(id: 1)
        assert_response :success
      end
    end
  end
end
