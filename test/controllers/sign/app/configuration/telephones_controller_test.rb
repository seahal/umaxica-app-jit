# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::TelephonesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    @token = UserToken.create!(
      user_id: @user.id, last_step_up_at: 1.minute.ago,
      last_step_up_scope: "configuration_telephone",
    )
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
    get new_sign_app_configuration_telephones_registration_url(ri: "jp"),
        headers: request_headers
    assert_response :success
  end

  test "destroy removes telephone when not last method" do
    tel1 = UserTelephone.create!(
      number: "+10000000000",
      user: @user,
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    UserTelephone.create!(
      number: "+10000000001",
      user: @user,
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    assert_difference("UserTelephone.count", -1) do
      delete sign_app_configuration_telephone_url(tel1, ri: "jp"), headers: request_headers
    end

    assert_response :see_other
    assert_predicate flash[:notice], :present?
  end

  test "destroy blocks removal when last method" do
    user = User.create!(status_id: UserStatus::NEYO)
    token = UserToken.create!(
      user_id: user.id, last_step_up_at: 1.minute.ago,
      last_step_up_scope: "configuration_telephone",
    )
    telephone = UserTelephone.create!(
      number: "+10000000002",
      user: user,
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    assert_no_difference("UserTelephone.count") do
      delete sign_app_configuration_telephone_url(telephone, ri: "jp"),
             headers: {
               "Host" => @host,
               "X-TEST-CURRENT-USER" => user.id,
               "X-TEST-SESSION-PUBLIC-ID" => token.public_id,
             }
    end

    assert_redirected_to sign_app_configuration_telephones_url(ri: "jp")
    assert_equal I18n.t("sign.app.configuration.telephone.destroy.last_method"), flash[:alert]
  end

  test "destroy rejects other user's public_id" do
    other_user = User.create!(status_id: UserStatus::NEYO)
    other_telephone = UserTelephone.create!(
      number: "+10000000003",
      user: other_user,
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    assert_no_difference("UserTelephone.count") do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete sign_app_configuration_telephone_url(other_telephone, ri: "jp"),
               headers: request_headers
      end
    end
  end

  test "destroy rejects missing public_id" do
    assert_no_difference("UserTelephone.count") do
      assert_raises(ActiveRecord::RecordNotFound) do
        delete sign_app_configuration_telephone_url("missing-public-id", ri: "jp"),
               headers: request_headers
      end
    end
  end
end
