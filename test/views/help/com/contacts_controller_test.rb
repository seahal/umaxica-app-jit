require "test_helper"

class Help::Com::ContactsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_help_com_contact_url
    assert_response :success
    assert_select "h1", I18n.t("controller.help.app.contacts.new.page_title")
    assert_select "form[action^='#{help_com_contacts_path}']"
  end
end
