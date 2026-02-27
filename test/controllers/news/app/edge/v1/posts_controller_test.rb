# typed: false
# frozen_string_literal: true

require "test_helper"

module News
  module App
    module Edge
      module V1
        class PostsControllerTest < ActionDispatch::IntegrationTest
          setup do
            host! ENV.fetch("NEWS_SERVICE_URL", "news.app.localhost")
          end

          test "should get index" do
            get news_app_edge_v1_posts_url

            assert_response :success
          end

          test "should get show" do
            get news_app_edge_v1_post_url(id: 1)

            assert_response :success
          end
        end
      end
    end
  end
end
