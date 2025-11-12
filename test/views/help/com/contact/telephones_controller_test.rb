require "test_helper"

class Help::Com::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = com_contacts(:one)
    # Create telephone for the contact since resource is singular
    @contact_telephone = ComContactTelephone.create!(
      com_contact: @contact,
      telephone_number: "+81901234567",
      expires_at: 24.hours.from_now
    )
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "should get edit with valid session" do
    @contact_telephone.generate_otp!

    contact_id = @contact.id
    telephone_id = @contact_telephone.id
    expires_at = 10.minutes.from_now.to_i

    puts "About to build URL with contact_id: #{contact_id}"
    url = edit_help_com_contact_telephone_url(contact_id: contact_id)
    puts "URL built: #{url}"

    puts "Building env hash..."
    env_hash = {
      "rack.session" => {
        com_contact_telephone_verification: {
          "id" => telephone_id,
          "contact_id" => contact_id,
          "expires_at" => expires_at
        }
      }
    }
    puts "Env hash built successfully"

    get url, env: env_hash

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

    patch help_com_contact_telephone_url(@contact), params: {
      com_contact_telephone: {
        otp_code: otp_code
      }
    }, env: {
      "rack.session" => {
        com_contact_telephone_verification: {
          "id" => @contact_telephone.id,
          "contact_id" => @contact.id,
          "expires_at" => 10.minutes.from_now.to_i
        }
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

    initial_attempts = @contact_telephone.otp_attempts_left

    patch help_com_contact_telephone_url(@contact), params: {
      com_contact_telephone: {
        otp_code: "000000"
      }
    }, env: {
      "rack.session" => {
        com_contact_telephone_verification: {
          "id" => @contact_telephone.id,
          "contact_id" => @contact.id,
          "expires_at" => 10.minutes.from_now.to_i
        }
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
