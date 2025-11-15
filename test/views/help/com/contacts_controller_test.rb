require "test_helper"

module Help::Com
  class ContactsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @category = com_contact_categories(:one)
    end

    test "should get new" do
      get new_help_com_contact_url

      assert_response :success
      # form_with doesn't set action attribute explicitly, so just check for form existence
      assert_select "form"
      assert_select "select[name='com_contact[contact_category_title]']"
    end

    test "should create contact with email and telephone" do
      assert_difference(
        [ "ComContact.count", "ComContactEmail.count", "ComContactTelephone.count" ], 1
      ) do
        post help_com_contacts_url, params: {
          com_contact: {
            contact_category_title: @category.title,
            confirm_policy: "1",
            email_address: "test@example.com",
            telephone_number: "+1234567890"
          },
          "cf-turnstile-response": "test_token"
        }
      end

      contact = ComContact.order(:created_at).last

      assert_redirected_to new_help_com_contact_email_url(
        contact_id: contact.public_id,
        host: "help.com.localhost"
      )
      assert_equal I18n.t("help.com.contacts.create.success"), flash[:notice]
    end

    test "should require valid category" do
      # Test with invalid/nil category
      assert_no_difference([ "ComContact.count", "ComContactEmail.count", "ComContactTelephone.count" ]) do
        post help_com_contacts_url, params: {
          com_contact: {
            contact_category_title: "", # Invalid: empty category
            confirm_policy: "1",
            email_address: "test@example.com",
            telephone_number: "+1234567890"
          },
          "cf-turnstile-response": "test_token"
        }
      end

      assert_response :unprocessable_entity
      assert_select "select[name='com_contact[contact_category_title]']"
    end

    test "should render new when validation fails" do
      assert_no_difference([ "ComContact.count", "ComContactEmail.count", "ComContactTelephone.count" ]) do
        post help_com_contacts_url, params: {
          com_contact: {
            contact_category_title: @category.title,
            confirm_policy: "0", # Invalid: not accepted
            email_address: "test@example.com",
            telephone_number: "+1234567890"
          },
          "cf-turnstile-response": "test_token"
        }
      end

      assert_response :unprocessable_entity
      assert_select "select[name='com_contact[contact_category_title]']"
    end

    test "should preserve input values on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          contact_category_title: @category.title,
          confirm_policy: "0",
          email_address: "preserve@example.com",
          telephone_number: "+9876543210"
        },
        "cf-turnstile-response": "test_token"
      }

      assert_response :unprocessable_entity
      # Form should be re-rendered with category select
      assert_select "select[name='com_contact[contact_category_title]']"
      assert_select "input[name='com_contact[confirm_policy]']"
    end

    test "should preserve unchecked confirm_policy on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          contact_category_title: @category.title,
          confirm_policy: "0", # Unchecked
          email_address: "test@example.com",
          telephone_number: "+1234567890"
        },
        "cf-turnstile-response": "test_token"
      }

      assert_response :unprocessable_entity
      # Checkbox should remain unchecked
      assert_select "input[name='com_contact[confirm_policy]'][type='checkbox']:not([checked])"
    end

    test "should preserve checked confirm_policy on validation error" do
      post help_com_contacts_url, params: {
        com_contact: {
          contact_category_title: "", # Invalid: empty category to trigger validation error
          confirm_policy: "1", # Checked
          email_address: "test@example.com",
          telephone_number: "+1234567890"
        },
        "cf-turnstile-response": "test_token"
      }

      assert_response :unprocessable_entity
      # Checkbox should remain checked
      assert_select "input[name='com_contact[confirm_policy]'][type='checkbox'][checked='checked']"
    end
  end
end
