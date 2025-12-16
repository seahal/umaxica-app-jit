require "test_helper"

module Sign
  module App
    module Authentication
      class GooglesControllerTest < ActionController::TestCase
        def setup
          @controller = GooglesController.new
        end

        test "should get new" do
          with_routing do |map|
            map.draw do
              resources :googles, controller: "sign/app/authentication/googles", only: [:new, :create]
            end

            get :new
            assert_response :redirect
            assert_redirected_to "/sign/google_oauth2"
          end
        end

        test "should post create" do
          with_routing do |map|
            map.draw do
              resources :googles, controller: "sign/app/authentication/googles", only: [:new, :create]
            end

            post :create
            assert_response :redirect
            assert_redirected_to "/sign/google_oauth2"
          end
        end
      end
    end
  end
end
