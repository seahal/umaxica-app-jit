# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sign_app_configuration_activities_url
    assert_response :success
  end

  test "includes link back to registration top" do
    get sign_app_configuration_activities_url

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path, text: "Back to Registration"
  end
end
