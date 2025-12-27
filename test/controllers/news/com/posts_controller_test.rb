# frozen_string_literal: true

require "test_helper"

module News
  module Com
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("NEWS_CORPORATE_URL", "news.com.localhost")
      end

      test "should get index" do
        get news_com_posts_url
        assert_response :success
      end

      test "should get show" do
        get news_com_post_url(id: 1)
        assert_response :success
      end
    end
  end
end
