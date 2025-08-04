# frozen_string_literal: true

require "test_helper"

class News::Org::RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get news_org_root_url
        assert_response :success
      end
end
