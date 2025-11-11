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
          contact_category_title: category.title
        }
      }
    end

    assert_response :redirect
    # Check redirect URL pattern (ID is UUID format)
    assert_match(%r{/contacts/[0-9a-f-]{36}/email/new}, response.redirect_url)
    assert_equal I18n.t("ja.help.com.contacts.create.success"), flash[:notice]
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
end
