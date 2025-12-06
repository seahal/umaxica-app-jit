require "test_helper"
require "uri"

class Help::Com::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Load fixture as ActiveRecord model, not Hash
    @contact = ComContact.find_by!(public_id: com_contacts(:one)["public_id"])
    # Delete any existing email for this contact to avoid conflicts
    ComContactEmail.where(com_contact_id: @contact.id).destroy_all
    # Create email for the contact since resource is singular
    @contact_email = ComContactEmail.create!(
      com_contact: @contact,
      email_address: "test@example.com",
      expires_at: 24.hours.from_now
    )
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect verification code" do
    skip "Hash id error needs fixing"
    @contact_email.generate_verifier!

    initial_attempts = @contact_email.verifier_attempts_left

    # セッションを設定
    patch help_com_contact_email_url(contact_id: @contact.id), params: {
      com_contact_email: {
        verification_code: "000000"
      }
    }, env: {
      "rack.session" => {
        com_contact_email_verification: {
          "id" => @contact_email.id,
          "contact_id" => @contact.id,
          "expires_at" => 15.minutes.from_now.to_i
        }
      }
    }

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_email_path(contact_id: @contact.id)}']"

    @contact_email.reload

    assert_equal initial_attempts - 1, @contact_email.verifier_attempts_left
    assert_not @contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
