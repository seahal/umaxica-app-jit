# frozen_string_literal: true

require "test_helper"

module Back::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    BACK_CORPORATE_URL = ENV.fetch("BACK_CORPORATE_URL", "back-corporate.example.com")

    test "should redirect to BACK_CORPORATE_URL" do
      get back_com_root_url

      assert_response :redirect
      assert_redirected_to "https://#{BACK_CORPORATE_URL}"
    end
  end
end
