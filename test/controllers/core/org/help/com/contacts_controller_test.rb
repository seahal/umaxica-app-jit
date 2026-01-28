# frozen_string_literal: true

require "test_helper"

module Core
  module Org
    module Help
      module Com
        class ContactsControllerTest < ActionDispatch::IntegrationTest
          test "should get index" do
            get core_org_help_com_contacts_url
            assert_response :success
          end

          test "should get new" do
            get new_core_org_help_com_contact_url
            assert_response :success
          end

          test "should create contact" do
            post core_org_help_com_contacts_url
            assert_response :success
          end

          test "should show contact" do
            get core_org_help_com_contact_url("id")
            assert_response :success
          end

          test "should get edit" do
            get edit_core_org_help_com_contact_url("id")
            assert_response :success
          end

          test "should update contact" do
            patch core_org_help_com_contact_url("id")
            assert_response :success
          end

          test "should destroy contact" do
            delete core_org_help_com_contact_url("id")
            assert_response :success
          end
        end
      end
    end
  end
end
