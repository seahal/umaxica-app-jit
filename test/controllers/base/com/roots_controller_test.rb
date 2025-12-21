# frozen_string_literal: true

require "test_helper"

module Base::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    BACK_CORPORATE_URL = ENV.fetch("BACK_CORPORATE_URL", "back-corporate.example.com")

    test "should redirect to BACK_CORPORATE_URL" do
      get base_com_root_url

      assert_response :success
    end
  end
end
