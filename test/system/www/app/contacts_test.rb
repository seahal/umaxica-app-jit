# frozen_string_literal: true

require "application_system_test_case"

module App
  class ContactsTest < ApplicationSystemTestCase
    test "visiting the root of contact new" do
      visit new_www_app_contact_url
      assert_selector "h1", text: I18n.t("controller.www.app.contacts.new.page_title")
    end
  end
end
