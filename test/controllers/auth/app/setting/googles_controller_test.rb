require "test_helper"

module Auth::App::Setting
  class GooglesControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get auth_app_setting_google_url

      assert_response :success
    end
  end
end
