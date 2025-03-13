# frozen_string_literal: true

require "test_helper"

module Net
  class HealthsControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      get net_health_url
      assert_response :success
      assert_select "a[href=?]", net_root_path, count: 2
    end

    test "should not get show when required json file" do
      get net_health_url
      assert_raises do
        JSON.parse(response.body)
      end
    end
  end
end
