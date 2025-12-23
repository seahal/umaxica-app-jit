require "test_helper"

module Help
  module Org
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV["HELP_STAFF_URL"] || "help.org.localhost"
        @contact = org_contacts(:one)
        @contact_category = org_contact_categories(:organization_inquiry)
        CloudflareTurnstile.test_mode = true
        CloudflareTurnstile.test_validation_response = { "success" => true }
        ActionMailer::Base.deliveries.clear
      end

      teardown do
        CloudflareTurnstile.test_mode = false
        CloudflareTurnstile.test_validation_response = nil
      end

      test "should get new" do
        get new_help_org_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should show contact" do
        get help_org_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end

      test "should get edit" do
        get edit_help_org_contact_url(@contact), headers: { "Host" => @host }

        assert_response :success
      end

      test "should create contact and send email" do
        assert_difference("OrgContact.count", 1) do
          perform_enqueued_jobs do
            post_valid_contact
          end
        end

        assert_equal 1, ActionMailer::Base.deliveries.size
      end

      test "should create contact and redirect to email page" do
        post_valid_contact

        assert_response :redirect
        assert_match %r{/contacts/[^/]+/email/new}, response.location
        assert_match %r{help\.org\.localhost}, response.location
      end

      test "should not create contact when turnstile fails" do
        CloudflareTurnstile.test_validation_response = { "success" => false }

        assert_no_difference("OrgContact.count") do
          post help_org_contacts_url, params: {
            org_contact: {
              contact_category_title: "ORGANIZATION_INQUIRY",
              email_address: "org_test@example.com",
              confirm_policy: "1"
            }
          }, headers: { "Host" => @host }
        end

        assert_response :unprocessable_content
        assert_select "div", /ロボットではないことの確認に失敗しました。/
      end

      test "should not create contact with invalid params" do
        assert_no_difference("OrgContact.count") do
          post help_org_contacts_url, params: {
            org_contact: {
              contact_category_title: "",
              email_address: "org_test@example.com",
              confirm_policy: "1"
            }
          }, headers: { "Host" => @host }
        end

        assert_response :unprocessable_content
      end

      test "should update contact and send notification email" do
        contact = org_contacts(:one)
        contact.org_contact_emails.create!(email_address: "notify-org@example.com")

        assert_difference("OrgContactTopic.count") do
          perform_enqueued_jobs do
            patch help_org_contact_url(contact), params: {
              org_contact_topic: {
                title: "New Topic",
                description: I18n.t("test_data.contact_topic_description")
              }
            }, headers: { "Host" => @host }
          end
        end

        assert_equal 0, ActionMailer::Base.deliveries.size
      end

      test "should update contact and redirect to contact page" do
        contact = org_contacts(:one)
        contact.org_contact_emails.create!(email_address: "notify-org@example.com")

        patch help_org_contact_url(contact), params: {
          org_contact_topic: {
            title: "New Topic",
            description: I18n.t("test_data.contact_topic_description")
          }
        }, headers: { "Host" => @host }

        assert_response :redirect
        assert_match %r{/contacts/#{contact.public_id}}, response.location
      end

      test "should update contact even with blank title" do
        contact = org_contacts(:one)

        assert_difference("OrgContactTopic.count") do
          patch help_org_contact_url(contact), params: {
            org_contact_topic: {
              title: "",
              description: I18n.t("test_data.contact_topic_description")
            }
          }, headers: { "Host" => @host }
        end

        assert_response :redirect
        assert_match %r{/contacts/#{contact.public_id}}, response.location
      end

      private

        def post_valid_contact
          post help_org_contacts_url, params: {
            org_contact: {
              contact_category_title: "ORGANIZATION_INQUIRY",
              email_address: "org_test@example.com",
              telephone_number: "+1234567890",
              confirm_policy: "1"
            }
          }, headers: { "Host" => @host }
        end
    end
  end
end
