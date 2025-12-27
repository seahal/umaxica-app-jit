# frozen_string_literal: true

require "test_helper"

module News
  module App
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("NEWS_SERVICE_URL", "news.app.localhost")
      end

      test "should return not implemented for show" do
        get news_app_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for new" do
        get new_news_app_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for create" do
        post news_app_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for edit" do
        get edit_news_app_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for update with PATCH" do
        patch news_app_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for update with PUT" do
        put news_app_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for destroy" do
        delete news_app_posts_url
        assert_response :not_implemented
      end
    end
  end
end
