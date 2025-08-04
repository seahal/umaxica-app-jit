# frozen_string_literal: true

require "test_helper"

class Help::Org::RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get help_org_root_url
        assert_response :success
      end
end
