# frozen_string_literal: true

require "test_helper"

module Docs
  module Org
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("DOCS_STAFF_URL", "docs.org.localhost")
      end

      test "should return not implemented for show" do
        get docs_org_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for new" do
        get new_docs_org_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for create" do
        post docs_org_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for edit" do
        get edit_docs_org_posts_url
        assert_response :not_implemented
      end

      test "should return not implemented for update with PATCH" do
        patch docs_org_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for update with PUT" do
        put docs_org_posts_url, params: {}
        assert_response :not_implemented
      end

      test "should return not implemented for destroy" do
        delete docs_org_posts_url
        assert_response :not_implemented
      end
    end
  end
end
