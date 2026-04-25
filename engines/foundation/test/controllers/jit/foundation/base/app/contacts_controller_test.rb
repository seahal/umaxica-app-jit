# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Base
      module App
        class ContactsControllerTest < ActionDispatch::IntegrationTest
          fixtures :users, :user_statuses, :app_contact_statuses, :app_contact_categories

          setup do
            host! ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost")
            @user = users(:one)
          end

          test "new redirects when not logged in" do
            get new_base_app_contact_url

            assert_response :redirect
          end
        end
      end
    end
  end
end
