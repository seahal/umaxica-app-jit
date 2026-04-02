# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    module Docs
      module Com
        class PostsControllerTest < ActionDispatch::IntegrationTest
          test "should get index" do
            get main_org_docs_com_posts_url

            assert_response :success
          end

          test "should get new" do
            get new_main_org_docs_com_post_url

            assert_response :success
          end

          test "should create post" do
            post main_org_docs_com_posts_url

            assert_response :success
          end

          test "should show post" do
            get main_org_docs_com_post_url("id")

            assert_response :success
          end

          test "should get edit" do
            get edit_main_org_docs_com_post_url("id")

            assert_response :success
          end

          test "should update post" do
            patch main_org_docs_com_post_url("id")

            assert_response :success
          end

          test "should destroy post" do
            delete main_org_docs_com_post_url("id")

            assert_response :success
          end
        end
      end
    end
  end
end
