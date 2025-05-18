# frozen_string_literal: true

require "test_helper"

module App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      assert_raise do
        get www_app_root_url
      end
    end
  end
end
