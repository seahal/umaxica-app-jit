# frozen_string_literal: true

require "test_helper"

module Bff::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    test "should redirect to BFF_CORPORATE_URL" do
      get bff_com_root_url

      assert_response :redirect
      assert_redirected_to "https://#{ENV['BFF_CORPORATE_URL']}"
    end
  end
end
