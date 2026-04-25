# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    require "test_helper"

    module Jit::Identity::Sign::App
      class ApplicationControllerTest < ActionDispatch::IntegrationTest
        test "includes expected concerns" do
          controller = ApplicationController.new

          assert_includes controller.class, ::Authentication::User
          assert_includes controller.class, ::Authorization::User
          assert_includes controller.class, ::Verification::User
        end

        test "includes expected concerns 2nd" do
          controller = ApplicationController.new

          assert_includes controller.class, RateLimit
          assert_includes controller.class, ::Preference::Global
        end

        test "authenticate_user! allows logged in users" do
          controller = ApplicationController.new
          controller.define_singleton_method(:logged_in?) { true }
          controller.define_singleton_method(:respond_to) { |_block| nil }

          # Should not raise or call respond_to
          assert_nothing_raised do
            controller.send(:authenticate_user!)
          end
        end
      end
    end
  end
end
