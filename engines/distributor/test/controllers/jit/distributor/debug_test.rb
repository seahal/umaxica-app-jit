# typed: false
# frozen_string_literal: true

require "test_helper"

module Jit
  module Distributor
    class DebugTest < ActionDispatch::IntegrationTest
      test "debug route helpers" do
        puts "ENV['DISTRIBUTOR_POST_ORG_URL']: #{ENV["DISTRIBUTOR_POST_ORG_URL"]}"

        health_url = distributor.post_org_health_url
        health_path = distributor.post_org_health_path

        puts "distributor.post_org_health_url: #{health_url}"
        puts "distributor.post_org_health_path: #{health_path}"

        assert_not_nil health_url
        assert_not_nil health_path
      end
    end
  end
end
