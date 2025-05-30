require "test_helper"

module Www::App
  class SessionServiceTest < ActionDispatch::IntegrationTest
    test "session test" do
      get www_app_root_url
      assert cookies["access_token"]
    end

    test "session test @health" do
      get www_app_health_url
      assert cookies["access_token"]
    end
  end
end
