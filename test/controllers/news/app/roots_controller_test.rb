# frozen_string_literal: true

require "test_helper"

class News::App::RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get news_app_root_url
        assert_response :success
      end
end
