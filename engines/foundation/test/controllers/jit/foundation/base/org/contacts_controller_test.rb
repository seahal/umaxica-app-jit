# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    module Main
      module Org
        class ContactsControllerTest < ActionDispatch::IntegrationTest
          fixtures :staffs, :staff_statuses, :org_contact_categories

          setup do
            host! ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost")
            @staff = staffs(:one)
            @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
            add_staff_contact_channels
            ensure_contact_references!
          end

          test "new redirects when not logged in" do
            get new_base_org_contact_url

            assert_response :redirect
          end

          test "should get new when logged in" do
            get new_base_org_contact_url, headers: @headers

            assert_response :success
          end

          test "should create contact when logged in" do
            category = org_contact_categories(:one)

            Jit::Security::TurnstileConfig.stub(:stealth_secret_key, nil) do
              assert_difference("OrgContact.count") do
                post foundation.base_org_contacts_url, headers: @headers, params: {
                  org_contact: {
                    category_id: category.id,
                    title: "Test Subject",
                    body: "Test message body",
                  },
                }
              end
            end

            assert_redirected_to foundation.base_org_contact_url(OrgContact.last)
          end

          test "should show contact when logged in" do
            contact = create_org_contact

            get foundation.base_org_contact_url(contact), headers: @headers

            assert_response :success
          end

          private

          def create_org_contact
            category = org_contact_categories(:one)
            contact = OrgContact.create!(
              category_id: category.id,
            )
            contact.org_contact_emails.create!(email_address: "test@example.com")
            contact.org_contact_topics.create!(title: "Test", description: "Test body")
            contact
          end

          def add_staff_contact_channels
            @staff.staff_emails.create!(
              address: "staff-#{SecureRandom.hex(4)}@example.com",
              staff_identity_email_status_id: StaffEmailStatus::VERIFIED,
            )
            @staff.staff_telephones.create!(
              number: "+1555#{rand(1_000_000..9_999_999)}",
              staff_identity_telephone_status_id: StaffTelephoneStatus::VERIFIED,
            )
          end

          def ensure_contact_references!
            OrgContactStatus.find_or_create_by!(id: OrgContactStatus::NOTHING)
            OrgContactStatus.find_or_create_by!(id: OrgContactStatus::COMPLETED)
          end
        end
      end
    end
  end
end
