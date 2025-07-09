# frozen_string_literal: true

require "test_helper"

module Docs
module Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get docs_org_root_url
      assert_response :success
    end
  end
end
end
