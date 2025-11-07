# frozen_string_literal: true

require "test_helper"

module Top::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to TOP_STAFF_URL" do
      get top_org_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['EDGE_STAFF_URL']}"
    end
  end
end
