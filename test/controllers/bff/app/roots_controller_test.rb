# frozen_string_literal: true

require "test_helper"

module Bff::App
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to BFF_SERVICE_URL" do
      get bff_app_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['BFF_SERVICE_URL']}"
    end
  end
end
