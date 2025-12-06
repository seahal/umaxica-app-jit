# frozen_string_literal: true

require "test_helper"

module Help
  module Com
    module Contact
      class TelephonesControllerTest < ActionDispatch::IntegrationTest
        setup do
          @host = ENV["HELP_CORPORATE_URL"] || "help.com.localhost"
          # Ensure required statuses exist (parent first)
          ComContactStatus.find_or_create_by!(title: "NULL_COM_STATUS") do |status|
            status.description = "root status"
            status.parent_title = nil
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(title: "SET_UP") do |status|
            status.description = "first step"
            status.parent_title = "NULL_COM_STATUS"
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(title: "CHECKED_EMAIL_ADDRESS") do |status|
            status.description = "second step completed"
            status.parent_title = "SET_UP"
            status.position = 0
            status.active = true
          end
          ComContactStatus.find_or_create_by!(title: "CHECKED_TELEPHONE_NUMBER") do |status|
            status.description = "telephone verified"
            status.parent_title = "CHECKED_EMAIL_ADDRESS"
            status.position = 0
            status.active = true
          end
          # Create a fresh contact with correct status instead of using fixture
          @contact = ComContact.create!(
            contact_category_title: "OTHERS",
            contact_status_title: "CHECKED_EMAIL_ADDRESS",
            confirm_policy: "1"
          )
          # Create telephone for verification
          @contact_telephone = ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15555555555",
            verifier_attempts_left: 3,
            verifier_expires_at: 15.minutes.from_now
          )
        end

        test "should get new with valid contact status" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          get new_help_com_contact_telephone_url(@contact), headers: { "Host" => @host }

          assert_response :success
        end

        test "should show error for invalid contact status" do
          @contact.update!(contact_status_title: "SET_UP")

          assert_raises(StandardError) do
            get new_help_com_contact_telephone_url(@contact), headers: { "Host" => @host }
          end
        end

        test "should require hotp_code parameter" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          post help_com_contact_telephone_url(@contact),
               params: { com_contact_telephone: { hotp_code: "" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should verify valid hotp code" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          # Recreate telephone fresh to avoid encryption issues in parallel tests
          ComContactTelephone.where(com_contact_id: @contact.id).delete_all
          fresh_telephone = ComContactTelephone.create!(
            com_contact: @contact,
            telephone_number: "+15555555555",
            verifier_attempts_left: 3,
            verifier_expires_at: 15.minutes.from_now
          )
          # Generate a valid HOTP code
          code = fresh_telephone.generate_hotp!

          post help_com_contact_telephone_url(@contact),
               params: { com_contact_telephone: { hotp_code: code } },
               headers: { "Host" => @host }

          assert_response :redirect
          @contact.reload

          assert_equal "CHECKED_TELEPHONE_NUMBER", @contact.contact_status_title
        end

        test "should reject invalid hotp code" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          @contact_telephone.generate_hotp!

          post help_com_contact_telephone_url(@contact),
               params: { com_contact_telephone: { hotp_code: "999999" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should reject expired hotp code" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          code = @contact_telephone.generate_hotp!
          @contact_telephone.update!(verifier_expires_at: 1.minute.ago)

          post help_com_contact_telephone_url(@contact),
               params: { com_contact_telephone: { hotp_code: code } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end

        test "should enforce max attempts" do
          @contact.update!(contact_status_title: "CHECKED_EMAIL_ADDRESS")
          @contact_telephone.generate_hotp!
          @contact_telephone.update!(verifier_attempts_left: 0)

          post help_com_contact_telephone_url(@contact),
               params: { com_contact_telephone: { hotp_code: "123456" } },
               headers: { "Host" => @host }

          assert_response :unprocessable_content
        end
      end
    end
  end
end
