require "test_helper"

module Help
  module App
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV["HELP_SERVICE_URL"] || "help.app.localhost"
        @contact = app_contacts(:one)
      end

      test "should get new" do
        get new_help_app_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should create contact" do
        post help_app_contacts_url, headers: { "Host" => @host }

        assert_response :unprocessable_content
      end

      test "should show contact" do
        get help_app_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end

      test "should get edit" do
        get edit_help_app_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end

      # Turnstile Widget Verification Tests
      # test "new contact page renders Turnstile widget" do
      #   get new_help_app_contact_url, headers: { "Host" => @host }
      #
      #   assert_response :success
      #   assert_select ".cf-turnstile", minimum: 1
      # end
    end
  end
end
