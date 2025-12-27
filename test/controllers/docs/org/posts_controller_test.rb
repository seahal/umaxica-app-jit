# frozen_string_literal: true

require "test_helper"

module Docs
  module Org
    class PostsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("DOCS_STAFF_URL", "docs.org.localhost")
      end

      test "should get index" do
        get docs_org_posts_url
        assert_response :success
      end

      test "should get show" do
        get docs_org_post_url(id: 1)
        assert_response :success
      end
    end
  end
end
