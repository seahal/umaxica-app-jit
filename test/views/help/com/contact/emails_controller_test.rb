require "test_helper"

class Help::Com::Contact::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = com_contacts(:one)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_help_com_contact_email_url(@contact)

    assert_response :success
    assert_select "form[action^='#{help_com_contact_emails_path(@contact)}']"
    assert_select "input[name='com_contact_email[email_address]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should create contact email and redirect to edit" do
    assert_difference("ComContactEmail.count", 1) do
      post help_com_contact_emails_url(@contact), params: {
        com_contact_email: {
          email_address: "test@example.com"
        }
      }
    end

    assert_response :redirect
    created_email = ComContactEmail.last

    assert_match(%r{/contacts/#{Regexp.escape(@contact.id)}/emails/#{Regexp.escape(created_email.id)}/edit}, response.redirect_url)
    assert_equal I18n.t("help.com.contact.emails.create.success"), flash[:notice]

    # セッションに保存されているか確認
    assert_not_nil session[:com_contact_email_verification]
    assert_equal created_email.id, session[:com_contact_email_verification]["id"]
    assert_equal @contact.id, session[:com_contact_email_verification]["contact_id"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "invalid email should re-render new with errors" do
    assert_no_difference("ComContactEmail.count") do
      post help_com_contact_emails_url(@contact), params: {
        com_contact_email: {
          email_address: "invalid-email"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_emails_path(@contact)}']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit with valid session" do
    contact_email = @contact.com_contact_emails.create!(email_address: "test@example.com")
    contact_email.generate_verifier!

    # セッションを設定
    session[:com_contact_email_verification] = {
      id: contact_email.id,
      contact_id: @contact.id,
      expires_at: 15.minutes.from_now.to_i
    }

    get edit_help_com_contact_email_url(@contact, contact_email)

    assert_response :success
    assert_select "form[action^='#{help_com_contact_email_path(@contact, contact_email)}']"
    assert_select "input[name='com_contact_email[verification_code]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should redirect edit without valid session" do
    contact_email = @contact.com_contact_emails.create!(email_address: "test@example.com")

    get edit_help_com_contact_email_url(@contact, contact_email)

    assert_redirected_to new_help_com_contact_email_path(@contact)
    assert_equal I18n.t("help.com.contact.emails.edit.session_expired"), flash[:alert]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should verify email with correct code" do
    contact_email = @contact.com_contact_emails.create!(email_address: "test@example.com")
    verification_code = contact_email.generate_verifier!

    # セッションを設定
    session[:com_contact_email_verification] = {
      id: contact_email.id,
      contact_id: @contact.id,
      expires_at: 15.minutes.from_now.to_i
    }

    patch help_com_contact_email_url(@contact, contact_email), params: {
      com_contact_email: {
        verification_code: verification_code
      }
    }

    assert_redirected_to new_help_com_contact_telephone_path(@contact)
    assert_equal I18n.t("help.com.contact.emails.update.success"), flash[:notice]
    assert_nil session[:com_contact_email_verification]

    contact_email.reload

    assert contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect verification code" do
    contact_email = @contact.com_contact_emails.create!(email_address: "test@example.com")
    contact_email.generate_verifier!

    # セッションを設定
    session[:com_contact_email_verification] = {
      id: contact_email.id,
      contact_id: @contact.id,
      expires_at: 15.minutes.from_now.to_i
    }

    initial_attempts = contact_email.verifier_attempts_left

    patch help_com_contact_email_url(@contact, contact_email), params: {
      com_contact_email: {
        verification_code: "000000"
      }
    }

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_email_path(@contact, contact_email)}']"

    contact_email.reload

    assert_equal initial_attempts - 1, contact_email.verifier_attempts_left
    assert_not contact_email.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
