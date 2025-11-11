require "test_helper"

class Help::Com::ContactsControllerTest < ActionDispatch::IntegrationTest
  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_help_com_contact_url

    assert_response :success
    #    assert_select "h1", I18n.t("controller.help.app.contacts.new.page_title")
    assert_select "form[action^='#{help_com_contacts_path}']"
    assert_select "input[name='com_contact[confirm_policy]']"
    assert_select "select[name='com_contact[contact_category_title]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should create contact and redirect with notice" do
    category = com_contact_categories(:two)

    # Turnstile validation is bypassed in test environment, so contact should be created
    assert_difference("ComContact.count", 1) do
      post help_com_contacts_url, params: {
        com_contact: {
          confirm_policy: "1",  # Checkbox sends "1" when checked
          contact_category_title: category.title,
          com_contact_emails_attributes: {
            "0" => { email_address: "contact@example.com" }
          },
          com_contact_telephones_attributes: {
            "0" => { telephone_number: "+1234567890" }
          }
        }
      }
    end

    assert_response :redirect
    # Check redirect URL pattern (ID is UUID format)
    assert_match(%r{/contacts/[0-9a-f-]{36}/email/new}, response.redirect_url)
    assert_equal I18n.t("help.com.contacts.create.success"), flash[:notice]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "invalid form re-renders new with errors" do
    # Missing confirm_policy should fail validation
    assert_no_difference("ComContact.count") do
      post help_com_contacts_url, params: {
        com_contact: {
          confirm_policy: "0"  # Checkbox not checked
        }
      }
    end

    assert_response :unprocessable_entity
    # Form should be re-rendered with category select
    assert_select "select[name='com_contact[contact_category_title]']"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "invalid form preserves user input on error" do
    category = com_contact_categories(:one)

    assert_no_difference("ComContact.count") do
      post help_com_contacts_url, params: {
        com_contact: {
          confirm_policy: "1",
          contact_category_title: category.title,
          com_contact_emails_attributes: {
            "0" => { email_address: "test@example.com" }
          },
          com_contact_telephones_attributes: {
            "0" => { telephone_number: "" }  # Invalid: empty telephone
          }
        }
      }
    end

    assert_response :unprocessable_entity
    # Check that email field is rendered with the preserved value
    assert_select "input[type='email'][value='test@example.com']"
    # Check that telephone field is rendered (even if empty)
    assert_select "input[type='text'][name*='telephone_number']"
  end
  # rubocop:enable Minitest/MultipleAssertions
end
