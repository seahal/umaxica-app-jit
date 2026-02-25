# typed: false
# frozen_string_literal: true

require "test_helper"

module Core
  module Com
    module Contact
      class TelephonesControllerTest < ActionDispatch::IntegrationTest
        fixtures :com_contacts, :com_contact_categories, :com_contact_statuses

        setup do
          @contact = com_contacts(:verified_email_complete)
          @contact_telephone = ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15555555555",
            expires_at: 1.day.from_now,
          )
          @host = "www.com.localhost".freeze
        end

        test "should get new" do
          host! @host
          get new_core_com_contact_telephone_url(contact_id: @contact.public_id)

          assert_response :success
        end

        test "should verify hotp code successfully" do
          host! @host
          code = @contact_telephone.generate_hotp!

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: code },
          }

          assert_response :redirect
          # Check redirect location if necessary, but response :redirect is good start

          @contact.reload

          assert_equal ComContactStatus::CHECKED_TELEPHONE_NUMBER, @contact.status_id

          @contact_telephone.reload

          assert @contact_telephone.activated
        end

        test "should not verify with invalid code" do
          host! @host
          @contact_telephone.generate_hotp!

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: "000000" }, # Invalid code
          }

          assert_response :unprocessable_content
          @contact_telephone.reload

          assert_equal 2, @contact_telephone.verifier_attempts_left # Started at 3
        end

        test "should fail if code is blank" do
          host! @host

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: "" },
          }

          assert_response :unprocessable_content
        end

        test "should fail if max attempts reached" do
          host! @host
          @contact_telephone.generate_hotp!
          @contact_telephone.update!(verifier_attempts_left: 0)

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: "123456" },
          }

          assert_response :unprocessable_content
          # Should validation error for max attempts
        end

        test "should fail if expired" do
          host! @host
          @contact_telephone.generate_hotp!
          @contact_telephone.update!(verifier_expires_at: 1.minute.ago)

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: "123456" },
          }

          assert_response :unprocessable_content
        end

        test "should raise error if contact not found" do
          host! @host

          assert_raises(StandardError) do
            get new_core_com_contact_telephone_url(contact_id: "invalid-id")
          end
        end

        test "should raise error if contact status is invalid" do
          host! @host
          @contact.update!(status_id: ComContactStatus::NEYO)

          assert_raises(StandardError) do
            get new_core_com_contact_telephone_url(contact_id: @contact.public_id)
          end
        end

        test "should handle last attempt failure" do
          host! @host
          @contact_telephone.generate_hotp!
          @contact_telephone.update!(verifier_attempts_left: 1)

          post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
            com_contact_telephone: { hotp_code: "invalid" },
          }

          assert_response :unprocessable_content

          @contact_telephone.reload

          assert_equal 0, @contact_telephone.verifier_attempts_left
        end

        test "should preserve query params on redirect" do
          host! @host
          code = @contact_telephone.generate_hotp!

          post core_com_contact_telephone_url(contact_id: @contact.public_id, ct: "test"), params: {
            com_contact_telephone: { hotp_code: code },
          }

          assert_response :redirect
          assert_includes @response.redirect_url, "ct=test"
        end

        test "should raise error if contact telephone not found" do
          host! @host
          @contact_telephone.destroy!

          assert_raises(StandardError) do
            post core_com_contact_telephone_url(contact_id: @contact.public_id), params: {
              com_contact_telephone: { hotp_code: "123456" },
            }
          end
        end
      end
    end
  end
end
