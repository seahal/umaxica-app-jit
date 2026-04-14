# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class EdgeV0JsonApiTest < ActiveSupport::TestCase
    class TestController
      include Sign::EdgeV0JsonApi

      attr_accessor :request

      def initialize
        @request = ActionDispatch::TestRequest.create
      end

      def logged_in?
        false
      end

      def render(**args)
        @render_args = args
      end

      def test_authenticate
        authenticate!
      end

      def test_ensure_json_request
        ensure_json_request
      end
    end

    test "ensure_json_request sets format to json" do
      controller = TestController.new
      controller.test_ensure_json_request

      assert_equal :json, controller.request.format.symbol
    end

    test "authenticate renders unauthorized when not logged in" do
      controller = TestController.new
      controller.test_authenticate

      assert_equal({ error: "Unauthorized" }, controller.instance_variable_get(:@render_args)[:json])
      assert_equal :unauthorized, controller.instance_variable_get(:@render_args)[:status]
    end

    test "activate_edge_v0_json_api is a valid class method" do
      assert_respond_to TestController, :activate_edge_v0_json_api
    end
  end
end
