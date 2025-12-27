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

      test "should get new" do
        get new_news_com_post_url
        assert_response :success
      end

      test "should create post" do
        post news_com_posts_url, params: {}
        assert_response :redirect
      end

      test "should get edit" do
        get edit_news_com_post_url(id: 1)
        assert_response :success
      end

      test "should update post" do
        patch news_com_post_url(id: 1), params: {}
        assert_response :redirect
      end

      test "should destroy post" do
        delete news_com_post_url(id: 1)
        assert_response :redirect
      end
    end
  end
end
