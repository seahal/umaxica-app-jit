require "test_helper"

module Sign
  module App
    module Authentication
      class ApplesControllerTest < ActionDispatch::IntegrationTest
        test "should get new" do
          with_routing do |set|
            set.draw do
              get "/sign/app/authentication/apples/new", to: "sign/app/authentication/apples#new"
            end

            get "/sign/app/authentication/apples/new"

            assert_response :redirect
            assert_redirected_to "/sign/apple"
          end
        end

        test "should post create" do
          with_routing do |set|
            set.draw do
              post "/sign/app/authentication/apples", to: "sign/app/authentication/apples#create"
            end

            post "/sign/app/authentication/apples"

            assert_response :redirect
            assert_redirected_to "/sign/apple"
          end
        end
      end
    end
  end
end
