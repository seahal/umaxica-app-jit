# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module Com
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      fixtures :com_contact_categories

      setup do
        host! ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")
      end

      test "should get new" do
        get new_main_com_contact_url

        assert_response :success
      end

      test "should create contact" do
        category = com_contact_categories(:one)

        assert_difference("ComContact.count") do
          post main_com_contacts_url, params: {
            com_contact: {
              category_id: category.id,
              email_address: "test@example.com",
              title: "Test Subject",
              body: "Test message body",
              confirm_policy: "1",
            },
          }
        end

        assert_redirected_to main_com_contact_url(ComContact.last)
      end

      test "should show contact" do
        contact = create_com_contact

        get main_com_contact_url(contact)

        assert_response :success
      end

      private

      def create_com_contact
        category = com_contact_categories(:one)
        contact = ComContact.create!(
          category_id: category.id,
          confirm_policy: true,
        )
        contact.create_com_contact_email!(email_address: "test@example.com")
        contact.create_com_contact_topic!(title: "Test", description: "Test body")
        contact
      end
    end
  end
end
