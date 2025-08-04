# frozen_string_literal: true

require "test_helper"

module Www
  module Org
    class RootsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get apex_org_root_url
        assert_response :success
      end
    end
  end
end
