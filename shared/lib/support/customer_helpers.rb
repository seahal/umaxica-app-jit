# typed: false
# frozen_string_literal: true

module CustomerHelpers
  def ensure_customer_reference_records!
    [CustomerStatus::ACTIVE, CustomerStatus::NOTHING, CustomerStatus::RESERVED].each do |id|
      CustomerStatus.find_or_create_by!(id: id)
    end
    [CustomerVisibility::NOBODY, CustomerVisibility::CUSTOMER, CustomerVisibility::STAFF,
     CustomerVisibility::BOTH,].each do |id|
      CustomerVisibility.find_or_create_by!(id: id)
    end
    [1, 2, 3, 4, 5, 6, 7].each do |id|
      CustomerEmailStatus.find_or_create_by!(id: id)
      CustomerTelephoneStatus.find_or_create_by!(id: id)
    end
    [1, 2, 3, 4, 5].each do |id|
      CustomerPasskeyStatus.find_or_create_by!(id: id)
    end
    [1, 2, 3, 4].each do |id|
      CustomerSecretKind.find_or_create_by!(id: id)
    end
    [1, 2, 3, 4, 5, 6].each do |id|
      CustomerSecretStatus.find_or_create_by!(id: id)
    end
  end

  def ensure_customer_token_reference_records!
    CustomerTokenBindingMethod.ensure_defaults!
    CustomerTokenDbscStatus.ensure_defaults!
    [CustomerTokenKind::BROWSER_WEB, CustomerTokenKind::CLIENT_IOS, CustomerTokenKind::CLIENT_ANDROID].each do |id|
      CustomerTokenKind.find_or_create_by!(id: id)
    end
    [CustomerTokenStatus::NOTHING, CustomerTokenStatus::ACTIVE, CustomerTokenStatus::EXPIRED].each do |id|
      CustomerTokenStatus.find_or_create_by!(id: id)
    end
  end

  def create_verified_customer_with_email(email_address: "customer@example.com", status: CustomerStatus::ACTIVE)
    ensure_customer_reference_records!
    ensure_customer_token_reference_records!
    customer = Customer.create!(status_id: status, visibility_id: CustomerVisibility::CUSTOMER)
    CustomerEmail.create!(
      customer: customer,
      address: email_address,
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
      confirm_policy: "1",
    )
    customer
  end
end

ActiveSupport.on_load(:active_support_test_case) { include CustomerHelpers }
