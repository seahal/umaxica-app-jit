require "test_helper"

module Help
  module Org
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV["HELP_STAFF_URL"] || "help.org.localhost"
        @contact = org_contacts(:one)
      end

      test "should get new" do
        get new_help_org_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should create contact" do
        post help_org_contacts_url, headers: { "Host" => @host }

        assert_response :created
      end

      test "should show contact" do
        get help_org_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end

      test "should get edit" do
        get edit_help_org_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end
    end
  end
end
