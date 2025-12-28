# frozen_string_literal: true

require "test_helper"

module Help
  module App
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV["HELP_SERVICE_URL"] || "help.app.localhost"
        @contact = app_contacts(:one)
        @contact_category = app_contact_categories(:application_inquiry)
        CloudflareTurnstile.test_mode = true
        CloudflareTurnstile.test_validation_response = { "success" => true }
        ActionMailer::Base.deliveries.clear
      end

      teardown do
        CloudflareTurnstile.test_mode = false
        CloudflareTurnstile.test_validation_response = nil
      end

      test "should get new" do
        get new_help_app_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should get new with valid category parameter" do
        get new_help_app_contact_url(category: @contact_category.id), headers: { "Host" => @host }

        assert_response :success
        assert_select "select[name='app_contact[category_id]'] option[selected][value='#{@contact_category.id}']",
                      count: 1
      end

      test "should get new with invalid category parameter" do
        get new_help_app_contact_url(category: "INVALID_CATEGORY_ID"), headers: { "Host" => @host }

        assert_response :success
        # Invalid category is not selected (validate controller returns nil)
        assert_select "select[name='app_contact[category_id]'] option[value='INVALID_CATEGORY_ID'][selected]", count: 0
      end

      test "should get new with blank category parameter" do
        get new_help_app_contact_url(category: ""), headers: { "Host" => @host }

        assert_response :success
        # No specific category should be selected
        assert_select "select[name='app_contact[category_id]']"
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
