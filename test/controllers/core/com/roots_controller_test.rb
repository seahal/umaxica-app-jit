# frozen_string_literal: true

require "test_helper"

module Core::Com
  class RootsControllerTest < ActionDispatch::IntegrationTest
    CORE_CORPORATE_URL = ENV.fetch("CORE_CORPORATE_URL", ENV.fetch("BACK_CORPORATE_URL", "back-corporate.example.com"))

    test "should redirect to CORE_CORPORATE_URL" do
      get core_com_root_url

      assert_response :success
    end
  end
end
