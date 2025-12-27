# frozen_string_literal: true

require "test_helper"

module News
  module Com
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("NEWS_CORPORATE_URL", "news.com.localhost")
      end

      test "should return not implemented for show" do
        get news_com_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for new" do
        get new_news_com_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for create" do
        post news_com_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for edit" do
        get edit_news_com_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for update with PATCH" do
        patch news_com_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for update with PUT" do
        put news_com_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for destroy" do
        delete news_com_posts_url
        assert_response :not_implemented
      end
    end
  end
end
