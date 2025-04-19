require "test_helper"

module Www
  module Com
    module Preference
      class CookiesControllerTest < ActionDispatch::IntegrationTest
        test "should get edit" do
          get edit_www_com_preference_cookie_url
          assert_response :success
        end
      end
    end
  end
end
