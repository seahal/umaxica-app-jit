require "test_helper"

module Help
  module App
    module Contact
      class EmailsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["HELP_SERVICE_URL"] || "help.app.localhost"
          @contact = app_contacts(:one)
        end

        test "should get new" do
          get new_help_app_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :success
          assert_match(/Service contact email new pending/, response.body)
        end

        test "should create contact email" do
          post help_app_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :created
          assert_match(/Service contact email create pending/, response.body)
        end
      end
    end
  end
end
