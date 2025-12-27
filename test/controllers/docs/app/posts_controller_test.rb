# frozen_string_literal: true

require "test_helper"

module Docs
  module App
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("DOCS_SERVICE_URL", "docs.app.localhost")
      end

      test "should get index" do
        get docs_app_posts_url
        assert_response :success
      end

      test "should get show" do
        get docs_app_post_url(id: 1)
        assert_response :success
      end

      test "should get new" do
        get new_docs_app_post_url
        assert_response :success
      end

      test "should create post" do
        post docs_app_posts_url, params: {}
        assert_response :redirect
      end

      test "should get edit" do
        get edit_docs_app_post_url(id: 1)
        assert_response :success
      end

      test "should update post" do
        patch docs_app_post_url(id: 1), params: {}
        assert_response :redirect
      end

      test "should destroy post" do
        delete docs_app_post_url(id: 1)
        assert_response :redirect
      end
    end
  end
end
