# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module Com
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      fixtures :com_contact_categories

      setup do
        host! ENV.fetch("MAIN_CORPORATE_URL", "main.com.localhost")
        CloudflareTurnstile.test_mode = true
        CloudflareTurnstile.test_validation_response = { "success" => true }
        ensure_contact_references!
      end

      teardown do
        CloudflareTurnstile.test_mode = false
        CloudflareTurnstile.test_validation_response = nil
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
              telephone_number: "+15551234567",
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

      def ensure_contact_references!
        ComContactStatus.find_or_create_by!(id: ComContactStatus::NOTHING)
        ComContactStatus.find_or_create_by!(id: ComContactStatus::COMPLETED)
      end

      def create_com_contact
        category = com_contact_categories(:one)
        contact = ComContact.create!(
          category_id: category.id,
          confirm_policy: true,
        )
        contact.create_com_contact_email!(email_address: "test@example.com")
        contact.com_contact_topics.create!(title: "Test", description: "Test body")
        contact
      end
    end
  end
end
