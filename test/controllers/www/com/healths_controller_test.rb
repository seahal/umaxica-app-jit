# frozen_string_literal: true

require "test_helper"

module Com
  class HealthsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get www_com_health_url
      assert_response :success
      assert_equal "OK", @response.body
      assert_select "a[href=?]", www_app_root_path, count: 0
    end

    test "should get show when required json file" do
      get www_com_health_url(format: :json)
      assert_response :success
      assert_nothing_raised do
        assert_equal "OK", JSON.parse(response.body)['status']
      end
    end
  end
end
