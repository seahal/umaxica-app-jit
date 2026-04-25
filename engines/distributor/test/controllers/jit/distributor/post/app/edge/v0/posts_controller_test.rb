# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    require "test_helper"

    module Post
      module App
        module Edge
          module V0
            class PostsControllerTest < ActionDispatch::IntegrationTest
              setup do
                host! ENV.fetch("DISTRIBUTOR_POST_APP_URL", "docs.app.localhost")
              end

              test "should get index" do
                get distributor.post_app_edge_v0_posts_url

                assert_response :success
              end

              test "should get show" do
                get distributor.post_app_edge_v0_post_url(id: 1)

                assert_response :success
              end
            end
          end
        end
      end
    end
  end
end
