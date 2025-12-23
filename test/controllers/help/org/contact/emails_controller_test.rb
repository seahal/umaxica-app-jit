require "test_helper"

module Help
  module Org
    module Contact
      class EmailsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["HELP_STAFF_URL"] || "help.org.localhost"
          @contact = org_contacts(:one)
        end

        test "should get new" do
          get new_help_org_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :success
          assert_match(/Org contact email new pending/, response.body)
        end

        test "should create contact email" do
          post help_org_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :created
          assert_match(/Org contact email create pending/, response.body)
        end
      end
    end
  end
end
