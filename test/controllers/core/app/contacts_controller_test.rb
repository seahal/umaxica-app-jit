# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module App
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      fixtures :users, :user_statuses, :app_contact_statuses, :app_contact_categories

      setup do
        host! ENV.fetch("CORE_SERVICE_URL", "ww.app.localhost")
        @user = users(:one)
      end

      test "new redirects when not logged in" do
        get new_core_app_contact_url

        assert_response :redirect
      end
    end
  end
end
