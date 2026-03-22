# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

module Core
  module Com
    module Contact
      class EmailsControllerTest < ActionDispatch::IntegrationTest
        fixtures :com_contact_categories, :com_contact_statuses

        setup do
          @contact = ComContact.create!(
            category_id: ComContactCategory::SECURITY_ISSUE,
            status_id: ComContactStatus::SET_UP,
          )

          @contact_email = ComContactEmail.create!(
            com_contact: @contact,
            email_address: "test@example.com",
            verifier_expires_at: 1.day.from_now,
          )

          @contact_telephone = ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15555555555",
            expires_at: 1.day.from_now,
          )

          @host = "www.com.localhost".freeze
        end

        test "should get new" do
          host! @host
          get new_core_com_contact_email_url(contact_id: @contact.public_id)

          assert_response :success
        end

        class SmsVerifier
          attr_reader :called

          def initialize(expected_to, expected_msg_regex)
            @expected_to = expected_to
            @expected_msg_regex = expected_msg_regex
            @called = false
          end

          def send_message(to:, message:, subject: nil)
            _subject = subject
            return unless to == @expected_to && message.match?(@expected_msg_regex)

            @called = true
            true

          end
        end

        test "should verify hotp code successfully and send sms" do
          host! @host
          code = @contact_email.generate_hotp!

          verifier = SmsVerifier.new("+15555555555", /^PassCode => \d{6}$/)

          AwsSmsService.stub(:new, verifier) do
            post core_com_contact_email_url(contact_id: @contact.public_id), params: {
              com_contact_email: { hotp_code: code },
            }
          end

          assert verifier.called, "SMS should have been sent"
          assert_response :redirect

          @contact.reload

          assert_equal ComContactStatus::CHECKED_EMAIL_ADDRESS, @contact.status_id
          assert @contact_email.reload.activated
        end

        test "should handle verification without telephone side effect gracefully" do
          host! @host
          @contact_telephone.destroy!

          code = @contact_email.generate_hotp!

          # Should not call AwsSmsService
          AwsSmsService.stub(:new, -> { raise "Should not be called" }) do
            post core_com_contact_email_url(contact_id: @contact.public_id), params: {
              com_contact_email: { hotp_code: code },
            }
          end

          assert_response :redirect

          @contact.reload

          assert_equal ComContactStatus::CHECKED_EMAIL_ADDRESS, @contact.status_id
        end

        test "should not verify with invalid code" do
          host! @host
          @contact_email.generate_hotp!

          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "invalid" },
          }

          assert_response :unprocessable_content
          assert_equal 2, @contact_email.reload.verifier_attempts_left
        end

        test "should fail if code is blank" do
          host! @host
          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "" },
          }

          assert_response :unprocessable_content
        end

        test "should fail if expired" do
          host! @host
          @contact_email.generate_hotp!
          @contact_email.update!(verifier_expires_at: 1.minute.ago)

          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "123456" },
          }

          assert_response :unprocessable_content
        end

        test "should fail if max attempts reached" do
          host! @host
          @contact_email.generate_hotp!
          @contact_email.update!(verifier_attempts_left: 0)

          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "123456" },
          }

          assert_response :unprocessable_content
        end

        test "should handle last attempt failure" do
          host! @host
          @contact_email.generate_hotp!
          @contact_email.update!(verifier_attempts_left: 1)

          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "invalid" },
          }

          assert_response :unprocessable_content
          assert_equal 0, @contact_email.reload.verifier_attempts_left
        end

        test "should preserve query params on redirect" do
          host! @host
          code = @contact_email.generate_hotp!

          verifier = SmsVerifier.new("+15555555555", /^PassCode => \d{6}$/)

          AwsSmsService.stub(:new, verifier) do
            post core_com_contact_email_url(contact_id: @contact.public_id, ct: "test"), params: {
              com_contact_email: { hotp_code: code },
            }
          end

          assert_response :redirect
          assert_includes @response.redirect_url, "ct=test"
        end

        test "should handle missing contact" do
          host! @host
          get new_core_com_contact_email_url(contact_id: "missing")

          assert_response :not_found
        end

        test "should handle invalid contact status" do
          host! @host
          @contact.update!(status_id: ComContactStatus::NOTHING)
          get new_core_com_contact_email_url(contact_id: @contact.public_id)

          assert_response :unprocessable_content
        end

        test "should return not found when contact email is missing" do
          host! @host
          @contact_email.destroy!

          post core_com_contact_email_url(contact_id: @contact.public_id), params: {
            com_contact_email: { hotp_code: "123456" },
          }

          assert_response :not_found
        end

        test "should return bad request when contact id is blank" do
          host! @host
          get new_core_com_contact_email_url(contact_id: " ")

          assert_response :bad_request
        end
      end
    end
  end
end
