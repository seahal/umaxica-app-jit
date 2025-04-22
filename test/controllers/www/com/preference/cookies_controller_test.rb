require "test_helper"

module Www
  module Com
    module Preference
      class CookiesControllerTest < ActionDispatch::IntegrationTest
        test "should get edit" do
          get edit_www_com_preference_cookie_url
          assert_response :success
        end

        test "Breadcrumbs" do
          get www_app_root_url
          assert_select "nav ul li a[href=?]", www_app_root_url
          # assert_select "nav ul li a[href=?]", www_app_preference_url
        end
      end
    end
  end
end
