require "test_helper"

class Sign::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
  end

  def request_headers
    { "Host" => @host }
  end

  def login_user
    # Create a token for the user
    token = UserToken.create!(user_id: @user.id)

    # Generate a valid JWT token
    payload = {
      iat: Time.current.to_i,
      exp: 15.minutes.from_now.to_i,
      jti: SecureRandom.uuid,
      iss: @host,
      aud: "umaxica-api",
      sub: @user.id,
      type: "user"
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
    get new_sign_app_withdrawal_url, headers: request_headers

    assert_response :success
  end

  test "should create withdrawal and set withdrawn_at" do
    post sign_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(sign_app_root_url)}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_operator @user.withdrawn_at, :<=, Time.current
  end

  test "should prevent double withdrawal" do
    @user.update!(withdrawn_at: 1.day.ago)

    post sign_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(sign_app_root_url)}}, @response.location
    assert_equal I18n.t("sign.app.withdrawal.create.already_withdrawn"), flash[:alert]
  end

  test "should allow recovery within 1 month" do
    @user.update!(withdrawn_at: 15.days.ago)

    patch sign_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(sign_app_root_url)}}, @response.location
    assert_nil @user.reload.withdrawn_at
    assert_equal I18n.t("sign.app.withdrawal.update.recovered"), flash[:notice]
  end

  test "should prevent recovery after 1 month" do
    @user.update!(withdrawn_at: 45.days.ago)

    patch sign_app_withdrawal_url, headers: request_headers.merge("X-TEST-CURRENT-USER" => @user.id)

    assert_match %r{\A#{Regexp.escape(sign_app_root_url)}}, @response.location
    assert_not_nil @user.reload.withdrawn_at
    assert_equal I18n.t("sign.app.withdrawal.update.cannot_recover"), flash[:alert]
  end

  test "test user is user not staff" do
    assert_predicate @user, :user?, "User should be identified as user"
    assert_not @user.staff?, "User should not be identified as staff"
  end
end
