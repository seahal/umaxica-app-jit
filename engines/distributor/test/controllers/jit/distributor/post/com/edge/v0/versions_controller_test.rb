# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    require "test_helper"

    class Jit::Distributor::Post::Com::Edge::V0::VersionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("DISTRIBUTOR_POST_COM_URL", "docs.com.localhost")
      end

      test "should get index" do
        get distributor.post_com_edge_v0_post_versions_url(post_id: 1)

        assert_response :success
      end

      test "should get index as json" do
        get distributor.post_com_edge_v0_post_versions_url(post_id: 1, format: :json)

        assert_response :success
        json_response = response.parsed_body

        assert_equal 3, json_response.size
      end

      test "should get show" do
        get distributor.post_com_edge_v0_post_version_url(post_id: 1, id: 1)

        assert_response :success
      end

      test "should get show as json" do
        get distributor.post_com_edge_v0_post_version_url(post_id: 1, id: 1, format: :json)

        assert_response :success
        json_response = response.parsed_body

        assert_equal "1", json_response["id"]
        assert_equal "1.1.0", json_response["version"]
      end
    end
  end
end
