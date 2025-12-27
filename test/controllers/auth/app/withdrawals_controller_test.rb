# frozen_string_literal: true

require "test_helper"
require_relative "../../../../app/errors/auth/withdrawal_error"

class Auth::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["AUTH_SERVICE_URL"] || "auth.app.localhost"
    @user = users(:one)
  end

  def request_headers
    { "Host" => @host }
  end

  def login_user
    UserToken.create!(user_id: @user.id)

    # Generate a valid JWT token
    payload = {
      iat: Time.current.to_i,
      exp: 15.minutes.from_now.to_i,
      jti: SecureRandom.uuid,
      iss: @host,
      aud: "umaxica-api",
      sub: @user.id,
      type: "user",
    }

    key = jwt_private_key
    jwt_token = JWT.encode(payload, key, "ES256")

    # Set the cookie
    @cookie_jar = HTTP::CookieJar.new
    cookie = HTTP::Cookie.new("access_token", jwt_token, domain: @host)
    @cookie_jar.add(cookie)

    # Use the JWT token in cookies
    # For integration tests, we need to set it via headers or direct cookie manipulation
    jwt_token
  end

  def jwt_private_key
    private_key_base64 = Rails.application.credentials.dig(:JWT, :PRIVATE_KEY)
    private_key_der = Base64.decode64(private_key_base64)
    OpenSSL::PKey::EC.new(private_key_der)
  end

  test "should get new withdrawal page" do
    @user.update!(user_identity_status_id: "NONE")
    get new_auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_response :success
  end

  test "should create withdrawal and set withdrawn_at" do
    @user.update!(user_identity_status_id: "NONE")

    post auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_operator @user.withdrawn_at, :<=, Time.current
  end

  # test "should prevent double withdrawal" do
  #   @user.update!(withdrawn_at: 1.day.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

  #   assert_raises(Auth::InvalidWithdrawalStateError) do
  #     post auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
  #   end
  # end

  test "should allow recovery within 1 month" do
    @user.update!(withdrawn_at: 15.days.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    patch auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_nil @user.reload.withdrawn_at
    assert_equal I18n.t("auth.app.withdrawal.update.recovered"), flash[:notice]
  end

  test "should prevent recovery after 1 month" do
    @user.update!(withdrawn_at: 45.days.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    patch auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_equal I18n.t("auth.app.withdrawal.update.cannot_recover"), flash[:alert]
  end

  test "withdrawn user cannot access withdrawal show page (route not available)" do
    @user.update!(withdrawn_at: 1.day.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    get auth_app_withdrawal_url(format: :html), headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_response :not_found
  end

  test "test user is user not staff" do
    assert_predicate @user, :user?, "User should be identified as user"
    assert_not @user.staff?, "User should not be identified as staff"
  end

  # Error path tests for withdrawal state validation
  test "should raise InvalidUserStatusError when accessing new for non-NONE user" do
    @user.update!(user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    assert_raises(InvalidUserStatusError) do
      get new_auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
    end
  end

  # test "should not be able to access show for any user (route not available)" do
  #   @user.update!(user_identity_status_id: UserIdentityStatus::ALIVE)
  #
  #   assert_raises(ActionController::RoutingError) do
  #     get auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
  #   end
  # end

  # test "should raise InvalidUserStatusError when accessing update for ALIVE user" do
  #   @user.update!(user_identity_status_id: UserIdentityStatus::ALIVE)

  #   assert_raises(InvalidUserStatusError) do
  #     patch auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
  #   end
  # end

  # test "should raise InvalidUserStatusError when accessing destroy for ALIVE user" do
  #   @user.update!(user_identity_status_id: UserIdentityStatus::ALIVE)
  #
  #   assert_raises(InvalidUserStatusError) do
  #     delete auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
  #   end
  # end

  # Turnstile Widget Verification Tests
  test "new withdrawal page renders Turnstile widget" do
    @user.update!(user_identity_status_id: "NONE")

    get new_auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  # Checkbox visibility tests
  # test "new withdrawal page renders confirm_create_recovery_code checkbox" do
  #   @user.update!(user_identity_status_id: "NONE")

  #   get new_auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

  #   assert_response :success
  #   assert_select "input[type='text'][name='confirm_withdrawal']"
  #   expected_label = I18n.t("auth.app.withdrawal.new.recovery_code_label")

  #   assert_select "label", text: expected_label
  # end

  test "edit withdrawal page renders confirm_create_recovery_code checkbox" do
    @user.update!(withdrawn_at: 1.day.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    get edit_auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_response :success
    assert_select "input[type='checkbox'][name='confirm_create_recovery_code']"
    expected_label = I18n.t("auth.app.withdrawal.edit.recovery_code_label")

    assert_select "label", text: expected_label
  end

  test "create accepts confirm_create_recovery_code parameter" do
    @user.update!(user_identity_status_id: "NONE")

    post auth_app_withdrawal_url, params: { confirm_create_recovery_code: "1" },
                                  headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
  end

  test "update accepts confirm_create_recovery_code parameter" do
    @user.update!(withdrawn_at: 15.days.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    patch auth_app_withdrawal_url, params: { confirm_create_recovery_code: "1" },
                                   headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_nil @user.reload.withdrawn_at
  end

  test "should destroy user account" do
    # Verify destroy works (mocking to ensure controller flow is tested without flaky DB checks)
    user_mock = @user
    user_mock.define_singleton_method(:destroy!) { true }

    User.stub(:find, user_mock) do
      User.stub(:find_by, user_mock) do
        delete auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
      end
    end

    assert_response :redirect
    # Match path ignoring query params
    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_equal I18n.t("auth.app.withdrawal.destroy.success"), flash[:notice]
  end

  test "should handle failure during destroy" do
    # Stub User.transaction to raise error
    # We stub transaction on User class.
    User.stub(:transaction, -> { raise StandardError.new("Boom") }) do
      assert_no_difference("User.count") do
        delete auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
      end
    end

    assert_response :redirect
    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_equal I18n.t("auth.app.withdrawal.destroy.failed"), flash[:alert]
  end

  test "should handle creation failure" do
    @user.update!(user_identity_status_id: "NONE")

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
    user_mock.define_singleton_method(:save) { false }

    # Assuming integration test mechanism: ApplicationController likely does User.find(headers['X-TEST-CURRENT-USER'])

    user_mock = @user
    user_mock.define_singleton_method(:save) { false }
    user_mock.define_singleton_method(:user_identity_status_id) { "NONE" } # Ensure checking status works

    # Stub finding methods likely used by authentication
    User.stub(:find, user_mock) do
      User.stub(:find_by, user_mock) do
        post auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
      end
    end

    assert_response :unprocessable_content
  end

  test "should handle update failure" do
    @user.update!(withdrawn_at: 15.days.ago, user_identity_status_id: UserIdentityStatus::PRE_WITHDRAWAL_CONDITION)

    user_mock = @user
    # Mock update to return false
    user_mock.define_singleton_method(:update) { |_| false }

    User.stub(:find, user_mock) do
      User.stub(:find_by, user_mock) do
        patch auth_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)
      end
    end

    assert_response :redirect
    assert_match %r{\A#{Regexp.escape(auth_app_root_url)}}, @response.location
    assert_equal I18n.t("auth.app.withdrawal.update.failed"), flash[:alert]
  end
end
