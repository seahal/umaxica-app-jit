# frozen_string_literal: true

require "test_helper"

class Help::Com::HealthsControllerTest < ActionDispatch::IntegrationTest
      test "should get show" do
        get news_com_health_url
        assert_response :success
        assert_equal "OK", @response.body
        # assert_select "a[href=?]", www_com_root_path, count: 0
      end

      test "should get show with postfix" do
        get news_com_health_url(format: :html)
        assert_response :success
        assert_equal "OK", @response.body
        # assert_select "a[href=?]", www_com_root_path, count: 0
      end

      test "should not get show when required json file" do
        assert_raise do
          get news_com_health_url(format: :json)
        end
      end
end
