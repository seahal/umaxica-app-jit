require "test_helper"

module Sign
  module App
    module Authentication
      class GooglesControllerTest < ActionDispatch::IntegrationTest
        test "should get new" do
          with_routing do |set|
            set.draw do
              get "/sign/app/authentication/googles/new", to: "sign/app/authentication/googles#new"
            end

            get "/sign/app/authentication/googles/new"

            assert_response :redirect
            assert_redirected_to "/sign/google_oauth2"
          end
        end

        test "should post create" do
          with_routing do |set|
            set.draw do
              post "/sign/app/authentication/googles", to: "sign/app/authentication/googles#create"
            end

            post "/sign/app/authentication/googles"

            assert_response :redirect
            assert_redirected_to "/sign/google_oauth2"
          end
        end
      end
    end
  end
end
