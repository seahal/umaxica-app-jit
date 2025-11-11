require "test_helper"

class Help::Com::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = com_contacts(:one)
    # Create telephone for the contact since resource is singular
    @contact_telephone = ComContactTelephone.create!(
      telephone_number: "+81901234567",
      expires_at: 24.hours.from_now
    )
    @contact.update!(com_contact_telephone_id: @contact_telephone.id)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit with valid session" do
    @contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: @contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    get edit_help_com_contact_telephone_url(@contact)

    assert_response :success
    assert_select "form[action^='#{help_com_contact_telephone_path(@contact)}']"
    assert_select "input[name='com_contact_telephone[otp_code]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should redirect edit without valid session" do
    get edit_help_com_contact_telephone_url(@contact)

    assert_redirected_to help_com_root_path
    assert_equal I18n.t("help.com.contact.telephones.edit.session_expired"), flash[:alert]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should verify telephone with correct OTP" do
    otp_code = @contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: @contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    patch help_com_contact_telephone_url(@contact), params: {
      com_contact_telephone: {
        otp_code: otp_code
      }
    }

    assert_redirected_to help_com_contact_path(@contact)
    assert_equal I18n.t("help.com.contact.telephones.update.success"), flash[:notice]
    assert_nil session[:com_contact_telephone_verification]

    @contact_telephone.reload

    assert @contact_telephone.activated
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect OTP code" do
    @contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: @contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    initial_attempts = @contact_telephone.otp_attempts_left

    patch help_com_contact_telephone_url(@contact), params: {
      com_contact_telephone: {
        otp_code: "000000"
      }
    }

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_telephone_path(@contact)}']"

    @contact_telephone.reload

    assert_equal initial_attempts - 1, @contact_telephone.otp_attempts_left
    assert_not @contact_telephone.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
