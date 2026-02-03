# frozen_string_literal: true

require "test_helper"
require_relative "../../../../../app/errors/sign/withdrawal_error"

class Sign::App::Configuration::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    login_user
  end

  def request_headers
    headers = { "Host" => @host }
    if @user && @token
      headers["X-TEST-CURRENT-USER"] = @user.id
      headers["X-TEST-SESSION-PUBLIC-ID"] = @token.public_id
    end
    headers["Authorization"] = "Bearer #{@jwt_token}" if @jwt_token
    headers
  end

  def login_user
    @token = UserToken.create!(user_id: @user.id)

    # Generate a valid JWT token
    payload = {
      iat: Time.current.to_i,
      exp: 15.minutes.from_now.to_i,
      jti: SecureRandom.uuid,
      iss: @host,
      aud: "umaxica-api",
      sub: @user.id,
      type: "user",
      sid: @token.public_id,
    }

    key = jwt_private_key
    @jwt_token = JWT.encode(payload, key, "ES384")
  end

  def jwt_private_key
    private_key_base64 = Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
    private_key_der = Base64.decode64(private_key_base64)
    OpenSSL::PKey::EC.new(private_key_der)
  end

  test "should get new withdrawal page" do
    @user.update!(status_id: UserStatus::NEYO)
    get new_sign_app_configuration_withdrawal_url(ri: "jp"),
        headers: request_headers
    assert_response :success
  end

  test "should create withdrawal and set withdrawn_at" do
    @user.update!(status_id: UserStatus::NEYO)

    post sign_app_configuration_withdrawal_url(ri: "jp"),
         headers: request_headers

    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_operator @user.withdrawn_at, :<=, Time.current
  end

  # test "should prevent double withdrawal" do
  #   @user.update!(withdrawn_at: 1.day.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

  #   assert_raises(Sign::InvalidWithdrawalStateError) do
  #     post sign_app_configuration_withdrawal_url(ri: "jp"),
  #          headers: request_headers
  #   end
  # end

  test "should allow recovery within 1 month" do
    @user.update!(withdrawn_at: 15.days.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    patch sign_app_configuration_withdrawal_url(ri: "jp"),
          headers: request_headers

    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_nil @user.reload.withdrawn_at
    assert_equal I18n.t("sign.app.configuration.withdrawal.update.recovered"), flash[:notice]
  end

  test "should prevent recovery after 1 month" do
    @user.update!(withdrawn_at: 45.days.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    patch sign_app_configuration_withdrawal_url(ri: "jp"),
          headers: request_headers

    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_equal I18n.t("sign.app.configuration.withdrawal.update.cannot_recover"), flash[:alert]
  end

  test "withdrawn user can access withdrawal show page" do
    @user.update!(withdrawn_at: 1.day.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    get sign_app_configuration_withdrawal_url(ri: "jp"),
        headers: request_headers

    assert_response :success
  end

  test "test user is user not staff" do
    assert_predicate @user, :user?, "User should be identified as user"
    assert_not @user.staff?, "User should not be identified as staff"
  end

  # Error path tests for withdrawal state validation
  test "should raise InvalidUserStatusError when accessing new for non-NONE user" do
    @user.update!(status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    assert_raises(InvalidUserStatusError) do
      get new_sign_app_configuration_withdrawal_url(ri: "jp"),
          headers: request_headers
    end
  end

  # test "should not be able to access show for any user (route not available)" do
  #   @user.update!(status_id: UserStatus::ALIVE)
  #
  #   assert_raises(ActionController::RoutingError) do
  #     get sign_app_configuration_withdrawal_url(ri: "jp"),
  #         headers: request_headers
  #   end
  # end

  # test "should raise InvalidUserStatusError when accessing update for ALIVE user" do
  #   @user.update!(status_id: UserStatus::ALIVE)

  #   assert_raises(InvalidUserStatusError) do
  #     patch sign_app_configuration_withdrawal_url(ri: "jp"),
  #           headers: request_headers
  #   end
  # end

  # test "should raise InvalidUserStatusError when accessing destroy for ALIVE user" do
  #   @user.update!(status_id: UserStatus::ALIVE)
  #
  #   assert_raises(InvalidUserStatusError) do
  #     delete sign_app_configuration_withdrawal_url(ri: "jp"),
  #            headers: request_headers
  #   end
  # end

  # Turnstile Widget Verification Tests
  test "new withdrawal page renders Turnstile widget" do
    @user.update!(status_id: UserStatus::NEYO)

    get new_sign_app_configuration_withdrawal_url(ri: "jp"),
        headers: request_headers

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  # Checkbox visibility tests
  # test "new withdrawal page renders confirm_create_recovery_code checkbox" do
  #   @user.update!(status_id: UserStatus::NEYO)
  #
  #   get new_sign_app_configuration_withdrawal_url(ri: "jp"),
  #       headers: request_headers
  #
  #   assert_response :success
  #   assert_select "input[type='text'][name='confirm_withdrawal']"
  #   expected_label = I18n.t("sign.app.configuration.withdrawal.new.recovery_code_label")

  #   assert_select "label", text: expected_label
  # end

  test "edit withdrawal page renders confirm_create_recovery_code checkbox" do
    @user.update!(withdrawn_at: 1.day.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    get edit_sign_app_configuration_withdrawal_url(ri: "jp"),
        headers: request_headers

    assert_response :success
    assert_select "input[type='checkbox'][name='confirm_create_recovery_code']"
    expected_label = I18n.t("sign.app.configuration.withdrawal.edit.recovery_code_label")

    assert_select "label", text: expected_label
  end

  test "create accepts confirm_create_recovery_code parameter" do
    @user.update!(status_id: UserStatus::NEYO)

    post sign_app_configuration_withdrawal_url(ri: "jp"), params: { confirm_create_recovery_code: "1" },
                                                          headers: request_headers

    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
  end

  test "update accepts confirm_create_recovery_code parameter" do
    @user.update!(withdrawn_at: 15.days.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    patch sign_app_configuration_withdrawal_url(ri: "jp"), params: { confirm_create_recovery_code: "1" },
                                                           headers: request_headers

    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_nil @user.reload.withdrawn_at
  end

  test "should block destroy user account" do
    delete sign_app_configuration_withdrawal_url(ri: "jp"),
           headers: request_headers

    assert_response :redirect
    # Match path ignoring query params - should redirect to edit (recovery/status) page
    assert_match %r{\A#{Regexp.escape(edit_sign_app_configuration_withdrawal_url(ri: "jp"))}}, @response.location
    assert_equal I18n.t("sign.app.configuration.withdrawal.destroy.permanent_unavailable"), flash[:alert]
  end

  # test "should handle failure during destroy" do
  #   # This test is irrelevant while destroy is blocked
  # end

  test "should handle creation failure" do
    @user.update!(status_id: UserStatus::NEYO)

    # We need to stub current_user.save to return false.
    # Since we can't easily access the exact instance controller uses,
    # we can stub User.find (if used) or we can make the model invalid.
    # Let's try making the model invalid by mocking a validation error if possible.
    # But current_user is loaded from DB.
    # Alternative: Stub Rails.event.notify to verify failure path calls?
    # But to Trigger logic: else path of save.

    # Let's try to pass invalid data if possible, but create takes no params really?
    # It sets constants.

    # We can stub save using minitest stub on specific instance? No control over instance.
    # We can use define_method on User class temporarily?

    # Hacky way: define singleton method on ALL users? No.

    # Let's try stubbing User.find to return a user object where we stub save.
    # Note: `request_headers` implies we are using some test mechanism to set current user with X-TEST-CURRENT-USER.
    # If application controller uses that header to find user (likely User.find(id)), we can stub User.find.

    user_mock = @user
    user_mock.define_singleton_method(:save!) { raise ActiveRecord::RecordInvalid.new(User.new) }
    user_mock.define_singleton_method(:status_id) { UserStatus::NEYO } # Ensure checking status works

    # Stub finding methods likely used by authentication
    User.stub(:find, user_mock) do
      User.stub(:find_by, user_mock) do
        post sign_app_configuration_withdrawal_url(ri: "jp"),
             headers: request_headers
      end
    end

    assert_response :unprocessable_content
  end

  test "should handle update failure" do
    @user.update!(withdrawn_at: 15.days.ago, status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)

    user_mock = @user
    # Mock update to raise error
    user_mock.define_singleton_method(:update!) { |_| raise ActiveRecord::RecordInvalid.new(User.new) }

    User.stub(:find, user_mock) do
      User.stub(:find_by, user_mock) do
        patch sign_app_configuration_withdrawal_url(ri: "jp"),
              headers: request_headers
      end
    end

    assert_response :redirect
    assert_match %r{\A#{Regexp.escape(sign_app_root_url(ri: "jp"))}}, @response.location
    assert_equal I18n.t("sign.app.configuration.withdrawal.update.failed"), flash[:alert]
  end
end
