require "test_helper"

class Help::Com::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = com_contacts(:one)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_help_com_contact_telephone_url(@contact)

    assert_response :success
    assert_select "form[action^='#{help_com_contact_telephones_path(@contact)}']"
    assert_select "input[name='com_contact_telephone[telephone_number]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should create contact telephone and redirect to edit" do
    assert_difference("ComContactTelephone.count", 1) do
      post help_com_contact_telephones_url(@contact), params: {
        com_contact_telephone: {
          telephone_number: "+81-90-1234-5678"
        }
      }
    end

    assert_response :redirect
    created_telephone = ComContactTelephone.last

    assert_match(%r{/contacts/#{Regexp.escape(@contact.id)}/telephones/#{Regexp.escape(created_telephone.id)}/edit}, response.redirect_url)
    assert_equal I18n.t("help.com.contact.telephones.create.success"), flash[:notice]

    # セッションに保存されているか確認
    assert_not_nil session[:com_contact_telephone_verification]
    assert_equal created_telephone.id, session[:com_contact_telephone_verification]["id"]
    assert_equal @contact.id, session[:com_contact_telephone_verification]["contact_id"]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "invalid telephone should re-render new with errors" do
    assert_no_difference("ComContactTelephone.count") do
      post help_com_contact_telephones_url(@contact), params: {
        com_contact_telephone: {
          telephone_number: "invalid@telephone"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_telephones_path(@contact)}']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit with valid session" do
    contact_telephone = @contact.com_contact_telephones.create!(telephone_number: "+81-90-1234-5678")
    contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    get edit_help_com_contact_telephone_url(@contact, contact_telephone)

    assert_response :success
    assert_select "form[action^='#{help_com_contact_telephone_path(@contact, contact_telephone)}']"
    assert_select "input[name='com_contact_telephone[otp_code]']"
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should redirect edit without valid session" do
    contact_telephone = @contact.com_contact_telephones.create!(telephone_number: "+81-90-1234-5678")

    get edit_help_com_contact_telephone_url(@contact, contact_telephone)

    assert_redirected_to new_help_com_contact_telephone_path(@contact)
    assert_equal I18n.t("help.com.contact.telephones.edit.session_expired"), flash[:alert]
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should verify telephone with correct OTP" do
    contact_telephone = @contact.com_contact_telephones.create!(telephone_number: "+81-90-1234-5678")
    otp_code = contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    patch help_com_contact_telephone_url(@contact, contact_telephone), params: {
      com_contact_telephone: {
        otp_code: otp_code
      }
    }

    assert_redirected_to help_com_contact_path(@contact)
    assert_equal I18n.t("help.com.contact.telephones.update.success"), flash[:notice]
    assert_nil session[:com_contact_telephone_verification]

    contact_telephone.reload

    assert contact_telephone.activated
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "should reject incorrect OTP code" do
    contact_telephone = @contact.com_contact_telephones.create!(telephone_number: "+81-90-1234-5678")
    contact_telephone.generate_otp!

    # セッションを設定
    session[:com_contact_telephone_verification] = {
      id: contact_telephone.id,
      contact_id: @contact.id,
      expires_at: 10.minutes.from_now.to_i
    }

    initial_attempts = contact_telephone.otp_attempts_left

    patch help_com_contact_telephone_url(@contact, contact_telephone), params: {
      com_contact_telephone: {
        otp_code: "000000"
      }
    }

    assert_response :unprocessable_entity
    assert_select "form[action^='#{help_com_contact_telephone_path(@contact, contact_telephone)}']"

    contact_telephone.reload

    assert_equal initial_attempts - 1, contact_telephone.otp_attempts_left
    assert_not contact_telephone.activated
  end
  # rubocop:enable Minitest/MultipleAssertions
end
