require "test_helper"

class Help::Com::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_help_com_contact_url
    assert_response :success
    assert_select "h1", I18n.t("controller.help.app.contacts.new.page_title")
    assert_select "form[action^='#{help_com_contacts_path}']"
  end

  test "should create contact and redirect with notice" do
    category = contact_categories(:two)

    assert_difference("ServiceSiteContact.count", 1) do
      post help_com_contacts_url, params: {
        service_site_contact: {
          confirm_policy: true,
          contact_category_title: category.title,
          email_address: "test@example.com",
          telephone_number: "+819012345678",
          email_pass_code: 123456,
          telephone_pass_code: 123456,
          title: "Support needed",
          description: "Please help with onboarding."
        }
      }
    end

    assert_redirected_to new_help_com_contact_url
    assert_equal I18n.t("help.app.contacts.create.success"), flash[:notice]
  end

  test "invalid form re-renders new with errors" do
    assert_no_difference("ServiceSiteContact.count") do
      post help_com_contacts_url, params: {
        service_site_contact: {
          confirm_policy: false,
          email_address: "",
          telephone_number: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation"
    assert_equal I18n.t("help.app.contacts.create.failure"), flash[:alert]
  end
end
