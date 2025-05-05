require "test_helper"

module Www
  module Com
    module Preference
      class CookiesControllerTest < ActionDispatch::IntegrationTest
        test "should get edit" do
          ActionController::Base.allow_forgery_protection = true
          get edit_www_com_preference_cookie_url
          assert_select "form" do
            assert_select "input[type='hidden'][name='authenticity_token']"
            assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
            assert_select "input[type=?]", "submit"
          end
          assert_response :success
        end

        # test "Breadcrumbs" do
        #   get www_com_root_url
        #   # assert_select "nav ul li a[href=?]", www_com_root_url
        # end

        # test "checking cookie policy" do
        #   get edit_www_com_preference_cookie_url
        #   assert_nil cookies[:accept_tracking_cookies]
        #   patch www_com_preference_cookie_url, params: { accept_tracking_cookies: 1 }
        #   # assert cookies[:accept_tracking_cookies]
        #   assert_redirected_to edit_www_com_preference_cookie_url
        #   get edit_www_com_preference_cookie_url
        #   patch www_com_preference_cookie_url, params: { accept_tracking_cookies: "0" }
        #   assert cookies[:accept_tracking_cookies]
        #   assert_redirected_to edit_www_com_preference_cookie_url
        # end
      end
    end
  end
end
