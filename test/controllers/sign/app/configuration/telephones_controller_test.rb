# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    @token = UserToken.create!(user_id: @user.id)
    @telephone = OpenStruct.new(id: "1")
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "should get index" do
    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "should show up link on index page" do
    get sign_app_configuration_telephones_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end

  test "should get new" do
    get new_sign_app_configuration_telephone_url(ri: "jp"), headers: request_headers
    assert_response :success
  end
end
