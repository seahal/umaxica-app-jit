# frozen_string_literal: true

require "test_helper"

module Sign::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert controller.class.include?(Authn)
      assert controller.class.include?(RateLimit)
      assert controller.class.include?(DefaultUrlOptions)
    end

    test "authenticate_user! allows logged in users" do
      controller = ApplicationController.new
      controller.define_singleton_method(:logged_in?) { true }
      controller.define_singleton_method(:respond_to) { |&block| }

      # Should not raise or call respond_to
      assert_nothing_raised do
        controller.send(:authenticate_user!)
      end
    end
  end
end
