# frozen_string_literal: true

require "test_helper"

module Help::Com
  class ContactsViewTest < ActionDispatch::IntegrationTest
    setup do
      # Seed required data
      @category = ComContactCategory.find_or_create_by!(id: "SECURITY_ISSUE")
    end

    test "should get new" do
      get new_help_com_contact_url

      assert_response :success
      # form_with doesn't set action attribute explicitly, so just check for form existence
      assert_select "form"
      assert_select "select[name='com_contact[category_id]']"
    end

    # TODO: Uncomment when hotp_secret and hotp_counter columns are added via migration
    # test "should create contact with email and telephone" do
    #   assert_difference(
    #     [ "ComContact.count", "ComContactEmail.count", "ComContactTelephone.count" ], 1
    #   ) do
    #     post help_com_contacts_url, params: {
    #       com_contact: {
    #         category_id: @category.id,
    #         confirm_policy: "1",
    #         email_address: "test@example.com",
    #         telephone_number: "+1234567890"
    #       },
    #       "cf-turnstile-response": "test_token"
    #     }
    #   end
    #
    #   contact = ComContact.order(:created_at).last
    #   email = contact.com_contact_emails.first
    #
    #   # Check status is updated to SET_UP
    #   assert_equal "SET_UP", contact.contact_status_title
    #
    #   # Check HOTP is saved to email record
    #   assert_not_nil email.hotp_secret
    #   assert_not_nil email.hotp_counter
    #   assert_not_nil email.verifier_expires_at
    #
    #   assert_redirected_to new_help_com_contact_email_url(
    #     contact_id: contact.public_id,
    #     host: "help.com.localhost"
    #   )
    #   assert_equal I18n.t("help.com.contacts.create.success"), flash[:notice]
    # end

    test "should require valid category" do
      # Test with invalid/nil category
      assert_no_difference(["ComContact.count", "ComContactEmail.count", "ComContactTelephone.count"]) do
        post help_com_contacts_url, params: {
          com_contact: {
            category_id: "", # Invalid: empty category
            confirm_policy: "1",
            email_address: "test@example.com",
            telephone_number: "+1234567890",
          },
          "cf-turnstile-response": "test_token",
        }
      end

      assert_response :unprocessable_entity
      assert_select "select[name='com_contact[category_id]']"
    end

    test "should render new when validation fails" do
      assert_no_difference(["ComContact.count", "ComContactEmail.count", "ComContactTelephone.count"]) do
        post help_com_contacts_url, params: {
          com_contact: {
            category_id: @category.id,
            confirm_policy: "0", # Invalid: not accepted
            email_address: "test@example.com",
            telephone_number: "+1234567890",
          },
          "cf-turnstile-response": "test_token",
        }
      end

      assert_response :unprocessable_entity
      assert_select "select[name='com_contact[category_id]']"
    end

    test "should preserve input values on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          category_id: @category.id,
          confirm_policy: "0",
          email_address: "preserve@example.com",
          telephone_number: "+9876543210",
        },
        "cf-turnstile-response": "test_token",
      }

      assert_response :unprocessable_entity
      # Form should be re-rendered with category select
      assert_select "select[name='com_contact[category_id]']"
      assert_select "input[name='com_contact[confirm_policy]']"
    end

    test "should preserve unchecked confirm_policy on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          category_id: @category.id,
          confirm_policy: "0", # Unchecked
          email_address: "test@example.com",
          telephone_number: "+1234567890",
        },
        "cf-turnstile-response": "test_token",
      }

      assert_response :unprocessable_entity
      # Checkbox should remain unchecked
      assert_select "input[name='com_contact[confirm_policy]'][type='checkbox']:not([checked])"
    end

    test "should preserve checked confirm_policy on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          category_id: "", # Invalid: empty category to trigger validation error
          confirm_policy: "1", # Checked
          email_address: "test@example.com",
          telephone_number: "+1234567890",
        },
        "cf-turnstile-response": "test_token",
      }

      assert_response :unprocessable_entity
      # Checkbox should remain checked
      assert_select "input[name='com_contact[confirm_policy]'][type='checkbox'][checked='checked']"
    end
  end
end
