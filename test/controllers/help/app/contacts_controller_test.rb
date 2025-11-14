require "test_helper"

module Help
  module App
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV["HELP_SERVICE_URL"] || "help.app.localhost"
      end

      test "should get new" do
        get new_help_app_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should create contact" do
        post help_app_contacts_url, headers: { "Host" => @host }

        assert_response :created
      end
    end
  end
end
