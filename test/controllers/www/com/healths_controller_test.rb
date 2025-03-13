# frozen_string_literal: true

require "test_helper"

module Com
  class HealthsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get www_com_health_url
      assert_response :success
      #assert_select "a[href=?]", www_com_root_path, count: 2
    end

    test "should not get show when required json file" do
      get www_com_health_url
      assert_raises do
        JSON.parse(response.body)
      end
    end
  end
end
