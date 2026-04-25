# typed: false
# frozen_string_literal: true

    require "test_helper"

    module Post
      module Org
        module Edge
          module V0
            class PostsControllerTest < ActionDispatch::IntegrationTest
              setup do
                host! ENV.fetch("DISTRIBUTOR_POST_ORG_URL", "docs.org.localhost")
              end

              test "should get index" do
                get distributor.post_org_edge_v0_posts_url

                assert_response :success
              end

              test "should get show" do
                get distributor.post_org_edge_v0_post_url(id: 1)

                assert_response :success
              end
            end
          end
        end
      end
    end
  end
end
