# frozen_string_literal: true

require "test_helper"

module Help
  module Com
    class ContactsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @contact_category = com_contact_categories(:SECURITY_ISSUE)
        CloudflareTurnstile.test_mode = true
        CloudflareTurnstile.test_validation_response = { "success" => true }
        ActionMailer::Base.deliveries.clear
        @host = ENV["HELP_CORPORATE_URL"] || "help.com.localhost"
      end

      teardown do
        CloudflareTurnstile.test_mode = false
        CloudflareTurnstile.test_validation_response = nil
      end

      test "should get new" do
        get new_help_com_contact_url, headers: { "Host" => @host }

        assert_response :success
      end

      test "should show contact" do
        contact = com_contacts(:one)
        get help_com_contact_url(contact), headers: { "Host" => @host }

        assert_response :success
      end

      test "should get edit" do
        contact = com_contacts(:one)
        get edit_help_com_contact_url(contact), headers: { "Host" => @host }

        assert_response :success
      end

      # More tests to be added here

      test "should create contact and send email" do
        assert_difference("ComContact.count", 1) do
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
        assert_match %r{help\.com\.localhost}, response.location
      end

      test "should not create contact when turnstile fails" do
        CloudflareTurnstile.test_validation_response = { "success" => false }

        assert_no_difference("ComContact.count") do
          post help_com_contacts_url, params: {
            com_contact: {
              category_id: "SECURITY_ISSUE",
              email_address: "test@example.com",
              confirm_policy: "1",
            },
          }, headers: { "Host" => @host }
        end

        assert_response :unprocessable_content
        assert_select "div", /ロボットではないことの確認に失敗しました。/
      end

      test "should not create contact with invalid params" do
        assert_no_difference("ComContact.count") do
          post help_com_contacts_url, params: {
            com_contact: {
              category_id: "",
              email_address: "test@example.com",
              confirm_policy: "1",
            },
          }, headers: { "Host" => @host }
        end

        assert_response :unprocessable_content
      end

      test "should update contact and send notification email" do
        contact = com_contacts(:one)
        contact.create_com_contact_email(email_address: "notify@example.com")

        assert_difference("ComContactTopic.count") do
          perform_enqueued_jobs do
            patch help_com_contact_url(contact), params: {
              com_contact_topic: {
                title: "New Topic",
                description: I18n.t("test_data.contact_topic_description"),
              },
            }, headers: { "Host" => @host }
          end
        end

        assert_equal 1, ActionMailer::Base.deliveries.size
      end

      test "should update contact and redirect to contact page" do
        contact = com_contacts(:one)
        contact.create_com_contact_email(email_address: "notify@example.com")

        patch help_com_contact_url(contact), params: {
          com_contact_topic: {
            title: "New Topic",
            description: I18n.t("test_data.contact_topic_description"),
          },
        }, headers: { "Host" => @host }

        assert_response :redirect
        assert_match %r{/contacts/#{contact.public_id}}, response.location
      end

      test "should update contact even with blank title" do
        contact = com_contacts(:one)

        assert_difference("ComContactTopic.count") do
          patch help_com_contact_url(contact), params: {
            com_contact_topic: {
              title: "", # Invalid: title is blank
              description: I18n.t("test_data.contact_topic_description"),
            },
          }, headers: { "Host" => @host }
        end

        assert_response :redirect
        assert_match %r{/contacts/#{contact.public_id}}, response.location
      end

      private

      def post_valid_contact
        post help_com_contacts_url, params: {
          com_contact: {
            category_id: "SECURITY_ISSUE",
            email_address: "test@example.com",
            telephone_number: "123-456-7890",
            confirm_policy: "1",
          },
        }, headers: { "Host" => @host }
      end
    end
  end
end
