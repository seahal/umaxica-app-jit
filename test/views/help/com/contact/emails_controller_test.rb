# frozen_string_literal: true

require "test_helper"
require "uri"

class Help::Com::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :com_contacts

  setup do
    host! ENV.fetch("HELP_CORPORATE_URL", "help.com.localhost")
    # Load fixture by public_id to ensure we get ActiveRecord object
    @contact = ComContact.find_by!(public_id: "97463105827291840535")
    @contact.update!(status_id: "SET_UP")
    # Delete any existing email for this contact to avoid conflicts
    ComContactEmail.where(com_contact_id: @contact.id).destroy_all
    # Create email for the contact since resource is singular
    @contact_email = ComContactEmail.create!(
      com_contact: @contact,
      email_address: "test@example.com",
      expires_at: 24.hours.from_now,
    )
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect verification code" do
    @contact_email.generate_verifier!

    initial_attempts = @contact_email.verifier_attempts_left

    # Set session
    post help_com_contact_email_url(@contact), params: {
      com_contact_email: {
        hotp_code: "000000",
      },
    }

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_email_path(contact_id: @contact.public_id)}']"

    @contact_email.reload

    assert_equal initial_attempts - 1, @contact_email.verifier_attempts_left
    assert_not @contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
