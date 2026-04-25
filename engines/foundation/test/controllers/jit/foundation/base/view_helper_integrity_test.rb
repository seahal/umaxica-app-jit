# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    require "test_helper"

    # This test ensures all views use properly defined helpers
    # Run this after refactoring to catch missing helper definitions
    class CoreViewHelperIntegrityTest < ActionDispatch::IntegrationTest
      test "title helper is available in core views" do
        host! ENV.fetch("FOUNDATION_BASE_COM_URL", "base.com.localhost")

        get foundation.new_base_com_contact_url

        assert_response :success
      end

      test "get_language helper is available in core layouts" do
        host! ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost")
        user = users(:one)
        add_user_contact_channels(user)

        get foundation.base_app_root_url, headers: { "X-TEST-CURRENT-USER" => user.id.to_s }

        assert_response :success
        assert_match(/<html[^>]*lang=/, response.body)
      end

      test "core layouts load without errors" do
        user = users(:one)
        staff = staffs(:one)
        add_user_contact_channels(user)
        add_staff_contact_channels(staff)

        {
          app: { host: ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost"),
                 headers: { "X-TEST-CURRENT-USER" => user.id.to_s }, },
          com: { host: ENV.fetch("FOUNDATION_BASE_COM_URL", "base.com.localhost"), headers: {} },
          org: { host: ENV.fetch("FOUNDATION_BASE_ORG_URL", "base.org.localhost"),
                 headers: { "X-TEST-CURRENT-STAFF" => staff.id.to_s }, },
        }.each do |domain, config|
          host! config[:host]
          get foundation.send("base_#{domain}_root_url"), headers: config[:headers]

          assert_response :success, "Core #{domain.upcase} layout should render without errors"
        end
      end

      test "contact forms render all required helpers" do
        host! ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost")
        user = users(:one)
        add_user_contact_channels(user)

        get foundation.new_base_app_contact_url, headers: { "X-TEST-CURRENT-USER" => user.id.to_s }

        assert_response :success
        # Verify form uses proper URL helpers
        assert_select "form[action=?]", foundation.base_app_contacts_path
      end

      private

      def add_user_contact_channels(user)
        user.user_emails.create!(
          address: "user-#{SecureRandom.hex(4)}@example.com",
          user_email_status_id: UserEmailStatus::VERIFIED,
        )
        user.user_telephones.create!(
          number: "+1555#{rand(1_000_000..9_999_999)}",
          user_identity_telephone_status_id: UserTelephoneStatus::VERIFIED,
        )
      end

      def add_staff_contact_channels(staff)
        staff.staff_emails.create!(
          address: "staff-#{SecureRandom.hex(4)}@example.com",
          staff_identity_email_status_id: StaffEmailStatus::VERIFIED,
        )
        staff.staff_telephones.create!(
          number: "+1555#{rand(1_000_000..9_999_999)}",
          staff_identity_telephone_status_id: StaffTelephoneStatus::VERIFIED,
        )
      end
    end
  end
end
