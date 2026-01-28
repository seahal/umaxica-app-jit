# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    module News
      module Com
        class VersionsControllerTest < ActionDispatch::IntegrationTest
          test "should get new" do
            get new_core_org_news_com_post_version_url("post_id")
            assert_response :success
          end

          test "should create version" do
            post core_org_news_com_post_versions_url("post_id")
            assert_response :success
          end

          test "should get edit" do
            get edit_core_org_news_com_post_version_url("post_id", "id")
            assert_response :success
          end

          test "should update version" do
            patch core_org_news_com_post_version_url("post_id", "id")
            assert_response :success
          end

          test "should destroy version" do
            delete core_org_news_com_post_version_url("post_id", "id")
            assert_response :success
          end
        end
      end
    end
  end
end
