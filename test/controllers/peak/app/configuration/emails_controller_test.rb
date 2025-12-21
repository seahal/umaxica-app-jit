require "test_helper"

module Peak::App::Configuration
  class EmailsControllerTest < ActionDispatch::IntegrationTest
    test "should get new and edit forms" do
      # new form
      get new_peak_app_configuration_email_url

      assert_response :success

      # edit form (controller does not fetch a real record)
      get edit_peak_app_configuration_email_url(id: "dummy-id")

      assert_response :success
    end

    test "should respond ok for create and update" do
      # create action returns head :ok
      post peak_app_configuration_emails_url

      assert_response :ok

      # update action returns head :ok (id param not used)
      patch peak_app_configuration_email_url(id: "dummy-id")

      assert_response :ok
    end
  end
end
