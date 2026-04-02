# typed: false
# frozen_string_literal: true

require "test_helper"

module Main
  module Org
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      fixtures :staffs, :staff_statuses, :org_contact_categories

      setup do
        host! ENV.fetch("MAIN_STAFF_URL", "main.org.localhost")
        @staff = staffs(:one)
        @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
      end

      test "new redirects when not logged in" do
        get new_main_org_contact_url

        assert_response :redirect
      end

      test "should get new when logged in" do
        get new_main_org_contact_url, headers: @headers

        assert_response :success
      end

      test "should create contact when logged in" do
        category = org_contact_categories(:one)

        assert_difference("OrgContact.count") do
          post main_org_contacts_url, headers: @headers, params: {
            org_contact: {
              category_id: category.id,
              email_address: "test@example.com",
              title: "Test Subject",
              body: "Test message body",
            },
          }
        end

        assert_redirected_to main_org_contact_url(OrgContact.last)
      end

      test "should show contact when logged in" do
        contact = create_org_contact

        get main_org_contact_url(contact), headers: @headers

        assert_response :success
      end

      private

      def create_org_contact
        category = org_contact_categories(:one)
        contact = OrgContact.create!(
          category_id: category.id,
          staff_id: @staff.id,
        )
        contact.create_org_contact_email!(email_address: "test@example.com")
        contact.create_org_contact_topic!(title: "Test", description: "Test body")
        contact
      end
    end
  end
end
