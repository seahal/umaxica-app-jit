require "test_helper"

module Sign
  module App
    module Authentication
      class ApplesControllerTest < ActionController::TestCase
        def setup
          @controller = ApplesController.new
        end

        test "should get new" do
          with_routing do |map|
            map.draw do
              resources :apples, controller: "sign/app/authentication/apples", only: [:new, :create]
            end

            get :new
            assert_response :redirect
            assert_redirected_to "/sign/apple"
          end
        end

        test "should post create" do
          with_routing do |map|
            map.draw do
              resources :apples, controller: "sign/app/authentication/apples", only: [:new, :create]
            end

            post :create
            assert_response :redirect
            assert_redirected_to "/sign/apple"
          end
        end
      end
    end
  end
end
