# frozen_string_literal: true

require "test_helper"

class Back::App::PreferencesControllerTest < ActionDispatch::IntegrationTest
  BACK_SERVICE_URL = ENV.fetch("BACK_SERVICE_URL", "back-service.example.com")

  setup do
    host! BACK_SERVICE_URL
  end
  test "should get show" do
    get back_app_preference_url

    assert_response :success
  end

  test "show page should display content" do
    get back_app_preference_url

    assert_response :success
    assert_select "h1"
    assert_select "div.configuration-list"
  end

  test "show page should have links in configuration list" do
    get back_app_preference_url

    assert_response :success
    assert_select "div.configuration-list ul li a", minimum: 1
  end

  test "should render copyright in footer" do
    get back_app_preference_url

    assert_select "footer" do
      assert_select "small", text: /^©/
      assert_select "small", text: /#{brand_name}$/
    end
  end
end
