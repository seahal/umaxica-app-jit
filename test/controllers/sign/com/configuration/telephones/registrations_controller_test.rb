# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::Configuration::Telephones::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    host! ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    @customer = create_verified_customer_with_email(email_address: "registration-#{SecureRandom.hex(4)}@example.com")
    @token = CustomerToken.create!(customer: @customer, customer_token_kind_id: CustomerTokenKind::BROWSER_WEB)
    satisfy_customer_verification(@token)
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-RESOURCE" => @customer.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "create registers telephone for current customer" do
    assert_enqueued_jobs 1, only: SmsDeliveryJob do
      assert_difference("CustomerTelephone.count", 1) do
        post sign_com_configuration_telephones_registration_url(ri: "jp"),
             params: { user_telephone: { raw_number: "+10000000039" } },
             headers: request_headers
      end
    end

    assert_response :redirect
    assert_redirected_to edit_sign_com_configuration_telephones_registration_url(ri: "jp")

    customer_telephone = CustomerTelephone.order(created_at: :desc).first

    assert_equal @customer.id, customer_telephone.customer_id
    assert_equal CustomerTelephoneStatus::UNVERIFIED, customer_telephone.customer_telephone_status_id
  end

  test "update successfully verifies telephone" do
    telephone = CustomerTelephone.create!(
      customer: @customer,
      raw_number: "+19999999999",
      customer_telephone_status_id: CustomerTelephoneStatus::UNVERIFIED,
      otp_private_key: "secret",
      otp_expires_at: 10.minutes.from_now,
    )

    Sign::Com::Configuration::Telephones::RegistrationsController.any_instance.stub(
      :current_registration_telephone,
      telephone,
    ) do
      Sign::Com::Configuration::Telephones::RegistrationsController.any_instance.stub(
        :complete_customer_telephone_verification, ->(*_args, &block) {
          block.call(telephone)
          :success
        },
      ) do
        patch sign_com_configuration_telephones_registration_url(ri: "jp"),
              params: { user_telephone: { pass_code: "123456" } },
              headers: request_headers

        assert_redirected_to sign_com_configuration_telephones_url(ri: "jp")
        assert_equal I18n.t("sign.app.registration.telephone.update.success"), flash[:notice]
      end
    end
  end
end
