# frozen_string_literal: true

require "test_helper"

module Bff::Org
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should get index" do
      get bff_org_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['BFF_STAFF_URL']}"
    end
  end
end
