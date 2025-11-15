# frozen_string_literal: true

require "test_helper"

module Sign::App::Setting
  class GooglesControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get sign_app_setting_google_url

      assert_response :success
    end
  end
end
