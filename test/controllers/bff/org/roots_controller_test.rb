# frozen_string_literal: true

require "test_helper"

module Bff::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get bff_org_root_url

      assert_response :success
    end
  end
end
