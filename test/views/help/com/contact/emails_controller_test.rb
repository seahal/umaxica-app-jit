require "test_helper"

class Help::Com::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = com_contacts(:one)
    # Create email for the contact since resource is singular
    @contact_email = ComContactEmail.create!(
      com_contact: @contact,
      email_address: "test@example.com",
      expires_at: 24.hours.from_now
    )
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit with valid session" do
    @contact_email.generate_verifier!

    # セッションを設定
    get edit_help_com_contact_email_url(@contact), params: {},
      env: {
        "rack.session" => {
          com_contact_email_verification: {
            "id" => @contact_email.id,
            "contact_id" => @contact.id,
            "expires_at" => 15.minutes.from_now.to_i
          }
        }
      }

    assert_response :success
    assert_select "form[action^='#{help_com_contact_email_path(@contact)}']"
    assert_select "input[name='com_contact_email[verification_code]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should redirect edit without valid session" do
    get edit_help_com_contact_email_url(@contact)

    assert_redirected_to help_com_root_path
    assert_equal I18n.t("help.com.contact.emails.edit.session_expired"), flash[:alert]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should verify email with correct code" do
    verification_code = @contact_email.generate_verifier!

    # Create telephone for the next step
    @contact_telephone = ComContactTelephone.create!(
      com_contact: @contact,
      telephone_number: "+81901234567",
      expires_at: 24.hours.from_now
    )

    # セッションを設定
    patch help_com_contact_email_url(@contact), params: {
      com_contact_email: {
        verification_code: verification_code
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

    assert_redirected_to edit_help_com_contact_telephone_path(@contact)
    assert_equal I18n.t("help.com.contact.emails.update.success"), flash[:notice]

    @contact_email.reload

    assert @contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect verification code" do
    @contact_email.generate_verifier!

    initial_attempts = @contact_email.verifier_attempts_left

    # セッションを設定
    patch help_com_contact_email_url(@contact), params: {
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
    assert_select "form[action^='#{help_com_contact_email_path(@contact)}']"

    @contact_email.reload

    assert_equal initial_attempts - 1, @contact_email.verifier_attempts_left
    assert_not @contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
