# frozen_string_literal: true

require "test_helper"

module Bff::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
      assert_includes controller.class, DefaultUrlOptions
      assert_includes controller.class, Bff::Concerns::Regionalization
    end

    test "logged_in_user? returns false" do
      controller = ApplicationController.new

      assert_not controller.send(:logged_in_user?)
    end
  end
end
