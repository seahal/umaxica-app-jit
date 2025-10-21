# frozen_string_literal: true

require "test_helper"

class Sign::App::Setting::TotpsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end

  test "should get index" do
    get sign_app_setting_totps_url, headers: { "Host" => @host }
    assert_response :success
  end
end
