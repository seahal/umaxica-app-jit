# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      test "should create session" do
        with_routing do |set|
          set.draw do
            post "/sign/app/sessions", to: "sign/app/sessions#create"
          end

          post "/sign/app/sessions"
          assert_response :success
          assert_equal I18n.t("common.ok"), response.body
        end
      end
    end
  end
end
