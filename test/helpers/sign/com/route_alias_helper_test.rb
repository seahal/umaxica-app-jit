# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  module Com
    class RouteAliasHelperTest < ActiveSupport::TestCase
      test "defines app-to-com route aliases" do
        instance = test_helper_instance
        app_methods = instance.methods.grep(/^sign_app_/)
        com_methods = instance.methods.grep(/^sign_com_/)

        found = false
        app_methods.each do |helper_name|
          expected_com_name = helper_name.to_s.sub("sign_app_", "sign_com_").to_sym
          next unless com_methods.include?(expected_com_name)

          found = true

          assert_respond_to instance, helper_name,
                            "Expected #{helper_name} to be aliased to #{expected_com_name}"
        end

        assert found, "Expected at least one app-to-com route alias to be defined"
      end

      test "defines apex app-to-com route aliases" do
        instance = test_helper_instance
        app_methods = instance.methods.grep(/^apex_app_/)
        com_methods = instance.methods.grep(/^apex_com_/)

        found = false
        app_methods.each do |helper_name|
          expected_com_name = helper_name.to_s.sub("apex_app_", "apex_com_").to_sym
          next unless com_methods.include?(expected_com_name)

          found = true

          assert_respond_to instance, helper_name,
                            "Expected #{helper_name} to be aliased to #{expected_com_name}"
        end

        assert found, "Expected at least one apex app-to-com route alias to be defined"
      end

      test "aliased method delegates to target method" do
        instance = test_helper_instance
        app_methods = instance.methods.grep(/^sign_app_/)
        com_methods = instance.methods.grep(/^sign_com_/)

        found = false
        app_methods.each do |helper_name|
          expected_com_name = helper_name.to_s.sub("sign_app_", "sign_com_").to_sym
          next unless com_methods.include?(expected_com_name)

          # Skip path helpers that require path parameters (contain :id, etc.)
          # Only test path helpers that can be called without arguments
          begin
            # Try calling the com method first to see if it requires parameters
            instance.public_send(expected_com_name)
          rescue ActionController::UrlGenerationError
            # This route requires parameters, skip it
            next
          end

          found = true
          app_result = instance.public_send(helper_name)
          com_result = instance.public_send(expected_com_name)

          assert_equal com_result, app_result,
                       "#{helper_name} should return same result as #{expected_com_name}"
        end

        assert found, "Expected at least one app-to-com route alias to test"
      end

      private

      def test_helper_instance
        @test_helper_instance ||= Class.new do
          include Rails.application.routes.url_helpers
          include Sign::Com::RouteAliasHelper

          define_method(:url_options) do
            { host: "sign.com.localhost" }
          end
        end.new
      end
    end
  end
end
