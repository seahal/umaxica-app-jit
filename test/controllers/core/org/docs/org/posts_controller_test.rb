# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    module Docs
      module Org
        class PostsControllerTest < ActionDispatch::IntegrationTest
          test "should get index" do
            get core_org_docs_org_posts_url
            assert_response :success
          end

          test "should get new" do
            get new_core_org_docs_org_post_url
            assert_response :success
          end

          test "should create post" do
            post core_org_docs_org_posts_url
            assert_response :success
          end

          test "should show post" do
            get core_org_docs_org_post_url("id")
            assert_response :success
          end

          test "should get edit" do
            get edit_core_org_docs_org_post_url("id")
            assert_response :success
          end

          test "should update post" do
            patch core_org_docs_org_post_url("id")
            assert_response :success
          end

          test "should destroy post" do
            delete core_org_docs_org_post_url("id")
            assert_response :success
          end
        end
      end
    end
  end
end
