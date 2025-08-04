# frozen_string_literal: true

require "test_helper"

class Auth::App::Setting::PasskeysControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
        end


        test "should get index" do
          get auth_app_setting_passkeys_url, headers: { "Host" => @host }
          assert_response :success
        end
end
