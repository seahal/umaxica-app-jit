# frozen_string_literal: true

require "test_helper"

module Help
  module Com
    module Contact
      class EmailsControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["HELP_CORPORATE_URL"] || "help.com.localhost"
          # Ensure required statuses exist (parent first)
          ComContactStatus.find_or_create_by!(id: "NULL_COM_STATUS") do |status|
            status.description = "root status"
            status.parent_id = nil
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(id: "SET_UP") do |status|
            status.description = "first step completed"
            status.parent_id = "NULL_COM_STATUS"
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(id: "CHECKED_EMAIL_ADDRESS") do |status|
            status.description = "email verified"
            status.parent_id = "SET_UP"
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(id: "NEYO") do |status|
            status.description = "initial state"
            status.parent_id = "NULL_COM_STATUS"
            status.position = 0
            status.active = true
          end
          # Create a fresh contact with correct status instead of using fixture
          @contact = ComContact.create!(
            category_id: "SECURITY_ISSUE",
            status_id: "SET_UP",
            confirm_policy: "1",
          )
          # Reload to ensure status is persisted
          @contact.reload
          # Create email for verification
          @contact_email = ComContactEmail.create!(
            com_contact: @contact,
            email_address: "test@example.com",
            verifier_attempts_left: 3,
            verifier_expires_at: 15.minutes.from_now,
          )
          # Create telephone for email verification flow
          @contact_telephone = ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15551234567",
            verifier_attempts_left: 3,
          )
        end

        test "should get new with valid contact status" do
          @contact.update!(status_id: "SET_UP")
          get new_help_com_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :success
        end

        test "should show error for invalid contact status" do
          @contact.update!(status_id: "NEYO")

          get new_help_com_contact_email_url(@contact), headers: { "Host" => @host }

          assert_response :unprocessable_entity
          assert_match(/無効なお問い合わせステータス|Invalid contact status/, response.body)
        end

        test "should require hotp_code parameter" do
          @contact.update!(status_id: "SET_UP")
          post help_com_contact_email_url(@contact),
               params: { com_contact_email: { hotp_code: "" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should verify valid hotp code" do
          @contact.update!(status_id: "SET_UP")
          # Reset email state
          @contact_email.update!(
            verifier_attempts_left: 3,
            verifier_expires_at: 15.minutes.from_now,
          )
          # Recreate telephone fresh to avoid encryption issues in parallel tests
          ComContactTelephone.where(com_contact_id: @contact.id).delete_all
          ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15551234567",
            verifier_attempts_left: 3,
          )
          # Generate a valid HOTP code
          code = @contact_email.generate_hotp!

          post help_com_contact_email_url(@contact),
               params: { com_contact_email: { hotp_code: code } },
               headers: { "Host" => @host }

          assert_response :redirect
          assert_match %r{/contacts/.*/telephone/new}, response.redirect_url
          @contact.reload

          assert_equal "CHECKED_EMAIL_ADDRESS", @contact.status_id
        end

        test "should reject invalid hotp code" do
          @contact.update!(status_id: "SET_UP")
          @contact_email.generate_hotp!

          post help_com_contact_email_url(@contact),
               params: { com_contact_email: { hotp_code: "999999" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should reject expired hotp code" do
          @contact.update!(status_id: "SET_UP")
          code = @contact_email.generate_hotp!
          @contact_email.update!(verifier_expires_at: 1.minute.ago)

          post help_com_contact_email_url(@contact),
               params: { com_contact_email: { hotp_code: code } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should enforce max attempts" do
          @contact.update!(status_id: "SET_UP")
          @contact_email.generate_hotp!
          @contact_email.update!(verifier_attempts_left: 0)

          post help_com_contact_email_url(@contact),
               params: { com_contact_email: { hotp_code: "123456" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end
      end
    end
  end
end
