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

      test "routes are configured" do
        assert_raise(StandardError) do
          get new_core_app_contact_url
        end
      end
    end
  end
end
