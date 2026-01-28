# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
  end

  def request_headers
    { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }
  end

  # ==========================================================================
  # Authentication Tests
  # ==========================================================================

  test "should redirect index when not logged in" do
    get sign_app_configuration_telephones_url(ri: "jp")
    assert_response :redirect
    target_path = new_sign_app_in_path
    assert_match %r{#{Regexp.escape(target_path)}\?.*ri=jp}, response.headers["Location"]
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect new when not logged in" do
    get new_sign_app_configuration_telephone_url(ri: "jp")
    assert_response :redirect
  end

  # ==========================================================================
  # Index Tests
  # ==========================================================================

  test "should get index" do
    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "index shows user telephones" do
    # Create a verified telephone for the user
    UserTelephone.create!(
      number: "+819012345678",
      user: @user,
      user_telephone_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "td", text: "+819012345678"
  end

  test "index does not show unverified telephones" do
    UserTelephone.create!(
      number: "+819098765432",
      user: @user,
      user_telephone_status_id: "UNVERIFIED_WITH_SIGN_UP"
    )

    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "td", text: "+819098765432", count: 0
  end

  # ==========================================================================
  # New Tests
  # ==========================================================================

  test "should get new" do
    get new_sign_app_configuration_telephone_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "new page renders telephone input form" do
    get new_sign_app_configuration_telephone_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "input[type=tel][name='user_telephone[telephone_number]']"
  end

  # ==========================================================================
  # Create Tests
  # ==========================================================================

  test "create initiates telephone verification and redirects to edit" do
    telephone_number = "+819011112222"

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    assert_response :redirect
    assert_match %r{/configuration/telephones/[^/]+/edit}, response.location

    # Verify UserTelephone was created
    user_telephone = UserTelephone.find_by(number: telephone_number)
    assert_not_nil user_telephone
    assert_equal "UNVERIFIED_WITH_SIGN_UP", user_telephone.user_telephone_status_id
  end

  test "create normalizes telephone number" do
    # Number without + prefix
    telephone_number = "8190-1234-5678"

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    assert_response :redirect

    # Verify number was normalized (+ prefix added, formatting removed)
    user_telephone = UserTelephone.find_by(number: "+819012345678")
    assert_not_nil user_telephone
  end

  test "create fails with invalid telephone format" do
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: "abc" }
         },
         headers: request_headers

    assert_response :unprocessable_content
  end

  test "create fails with duplicate verified telephone" do
    UserTelephone.create!(
      number: "+819033334444",
      user: users(:two),
      user_telephone_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: "+819033334444" }
         },
         headers: request_headers

    assert_response :unprocessable_content
  end

  test "create sends SMS with OTP" do
    telephone_number = "+819055556666"

    # AwsSmsService.send_message is stubbed globally in test/support/service_stubs.rb
    # Just verify the request succeeds and creates a telephone record with OTP data
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    assert_response :redirect

    # Verify UserTelephone was created with OTP data
    user_telephone = UserTelephone.find_by(number: telephone_number)
    assert_not_nil user_telephone
    assert_not_nil user_telephone.get_otp
  end

  # ==========================================================================
  # Edit Tests
  # ==========================================================================

  test "edit requires valid flow state" do
    # Create telephone but don't advance flow
    telephone = UserTelephone.create!(
      number: "+819077778888",
      user_telephone_status_id: "UNVERIFIED_WITH_SIGN_UP"
    )

    get edit_sign_app_configuration_telephone_url(telephone, ri: "jp"), headers: request_headers

    # Should redirect due to flow enforcement
    assert_response :redirect
  end

  test "edit shows OTP input form when flow is correct" do
    telephone_number = "+819099990000"

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    # Extract telephone ID from redirect location and make a separate request
    user_telephone = UserTelephone.find_by(number: telephone_number)
    get edit_sign_app_configuration_telephone_url(user_telephone, ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "input[name='user_telephone[pass_code]']"
  end

  test "edit redirects when telephone not found" do
    # Initiate verification to set flow state
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: "+819011111111" }
         },
         headers: request_headers

    # Try to access edit with non-existent ID
    get edit_sign_app_configuration_telephone_url(id: "nonexistent", ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_match %r{/configuration/telephones/new}, response.location
  end

  test "edit redirects when OTP expired" do
    telephone_number = "+819022222222"

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)

    # Expire the OTP
    user_telephone.update!(otp_expires_at: 1.hour.ago)

    # Try to access edit
    get edit_sign_app_configuration_telephone_url(user_telephone, ri: "jp"), headers: request_headers

    assert_response :redirect
  end

  # ==========================================================================
  # Update Tests
  # ==========================================================================

  # rubocop:disable Minitest/MultipleAssertions
  test "update with correct OTP verifies telephone and links to user" do
    telephone_number = "+819033333333"

    # Initiate verification
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)
    otp_data = user_telephone.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP
    patch sign_app_configuration_telephone_url(user_telephone, ri: "jp"),
          params: {
            user_telephone: { pass_code: correct_code }
          },
          headers: request_headers

    assert_response :redirect

    # Verify telephone was linked to user
    user_telephone.reload
    assert_equal @user.id, user_telephone.user_id
    assert_equal "VERIFIED_WITH_SIGN_UP", user_telephone.user_telephone_status_id
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "update with wrong OTP renders edit with error" do
    telephone_number = "+819044444444"

    # Initiate verification
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)

    # Submit wrong OTP
    patch sign_app_configuration_telephone_url(user_telephone, ri: "jp"),
          params: {
            user_telephone: { pass_code: "000000" }
          },
          headers: request_headers

    assert_response :unprocessable_content
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "update deletes telephone after max OTP attempts" do
    telephone_number = "+819055555555"

    # Initiate verification
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)

    # Make 3 failed attempts
    3.times do
      patch sign_app_configuration_telephone_url(user_telephone, ri: "jp"),
            params: {
              user_telephone: { pass_code: "000000" }
            },
            headers: request_headers
    end

    # Verify redirect and record deletion
    assert_response :redirect
    assert_nil UserTelephone.find_by(number: telephone_number)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "update clears OTP data after successful verification" do
    telephone_number = "+819066666666"

    # Initiate verification
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)
    otp_data = user_telephone.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Verify OTP data exists before verification
    assert_not_nil user_telephone.get_otp

    # Submit correct OTP
    patch sign_app_configuration_telephone_url(user_telephone, ri: "jp"),
          params: {
            user_telephone: { pass_code: correct_code }
          },
          headers: request_headers

    # Verify OTP data was cleared
    user_telephone.reload
    assert_nil user_telephone.get_otp
  end

  # ==========================================================================
  # Show Tests
  # ==========================================================================

  test "show displays verified telephone" do
    telephone_number = "+819077777777"

    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: telephone_number }
         },
         headers: request_headers

    user_telephone = UserTelephone.find_by(number: telephone_number)
    otp_data = user_telephone.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    patch sign_app_configuration_telephone_url(user_telephone, ri: "jp"),
          params: {
            user_telephone: { pass_code: correct_code }
          },
          headers: request_headers

    # Make a separate request to show page with headers
    get sign_app_configuration_telephone_url(user_telephone, ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "p", text: telephone_number
  end

  # ==========================================================================
  # Destroy Tests
  # ==========================================================================

  test "destroy removes telephone" do
    telephone = UserTelephone.create!(
      number: "+819088888888",
      user: @user,
      user_telephone_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    delete sign_app_configuration_telephone_url(telephone, ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_match %r{/configuration/telephones}, response.location

    # Verify telephone was marked as deleted
    telephone.reload
    assert_equal UserTelephoneStatus::DELETED, telephone.user_telephone_status_id
  end

  test "destroy returns not found for non-existent telephone" do
    delete sign_app_configuration_telephone_url(id: "nonexistent", ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_equal I18n.t("sign.app.configuration.telephone.destroy.not_found"), flash[:alert]
  end

  test "destroy does not allow deleting other user's telephone" do
    other_user = users(:two)
    telephone = UserTelephone.create!(
      number: "+819099999999",
      user: other_user,
      user_telephone_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    delete sign_app_configuration_telephone_url(telephone, ri: "jp"), headers: request_headers

    # Should not find the telephone since it belongs to another user
    assert_response :redirect
    assert_equal I18n.t("sign.app.configuration.telephone.destroy.not_found"), flash[:alert]
  end

  # ==========================================================================
  # Flow State Tests
  # ==========================================================================

  test "visiting index resets flow state" do
    # Start a flow
    post sign_app_configuration_telephones_url(ri: "jp"),
         params: {
           user_telephone: { telephone_number: "+819011110000" }
         },
         headers: request_headers

    # Visit index (should reset flow)
    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers

    # Try to access edit directly (should fail due to reset flow)
    user_telephone = UserTelephone.find_by(number: "+819011110000")
    get edit_sign_app_configuration_telephone_url(user_telephone, ri: "jp"), headers: request_headers

    assert_response :redirect
  end

  # ==========================================================================
  # i18n Tests
  # ==========================================================================

  test "configuration telephone i18n keys exist" do
    keys = %w[
      sign.app.configuration.telephone.index.title
      sign.app.configuration.telephone.new.title
      sign.app.configuration.telephone.edit.title
      sign.app.configuration.telephone.show.title
      sign.app.configuration.telephone.create.verification_code_sent
      sign.app.configuration.telephone.update.success
      sign.app.configuration.telephone.destroy.success
    ]

    keys.each do |key|
      assert_not_nil I18n.t(key, locale: :ja, default: nil), "Missing ja translation for #{key}"
      assert_not_nil I18n.t(key, locale: :en, default: nil), "Missing en translation for #{key}"
    end
  end
end
