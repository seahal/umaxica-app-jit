# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::Telephones::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @token = UserToken.create!(
      user_id: @user.id,
    )

    @sms_calls = [].freeze
    sms_calls = @sms_calls
    if defined?(AwsSmsService)
      @original_aws_sms_service_send_message = AwsSmsService.method(:send_message)
      AwsSmsService.singleton_class.send(:define_method, :send_message) do |**kwargs|
        sms_calls << kwargs
        true
      end
    end
  end

  teardown do
    return unless defined?(AwsSmsService) && @original_aws_sms_service_send_message

    original = @original_aws_sms_service_send_message
    AwsSmsService.singleton_class.send(:define_method, :send_message) do |**kwargs|
      original.call(**kwargs)
    end
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "create registers telephone for current user" do
    assert_difference("UserTelephone.count", 1) do
      post sign_app_configuration_telephones_registration_url(ri: "jp"),
           params: { user_telephone: { number: "+10000000009" } },
           headers: request_headers
    end

    assert_response :redirect
    assert_redirected_to edit_sign_app_configuration_telephones_registration_url(ri: "jp")

    user_telephone = UserTelephone.order(created_at: :desc).first
    assert_equal @user.id, user_telephone.user_id
    assert_equal UserTelephoneStatus::UNVERIFIED, user_telephone.user_telephone_status_id
    assert_equal 0, UserTelephone.where(user_id: 0).count
    assert_equal 1, @sms_calls.size
    assert_equal "+10000000009", @sms_calls.last[:to]
  end
end
