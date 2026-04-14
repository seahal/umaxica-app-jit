# typed: false
# frozen_string_literal: true

require "test_helper"

class Contact::ActorContextTest < ActiveSupport::TestCase
  test "returns canonical user contact details" do
    user = create_verified_user_with_email(email_address: "contact-user-#{SecureRandom.hex(4)}@example.com")
    user.user_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    context = Contact::ActorContext.new(actor: user)

    assert_equal user.user_emails.first.address, context.email_address
    assert_equal user.user_telephones.first.number, context.telephone_number
    assert_equal user.id, context.actor_id
    assert_equal "user", context.actor_type
    assert_predicate context, :ready?
  end

  test "returns canonical staff contact details" do
    staff = Staff.create!(status_id: StaffStatus::NOTHING)
    staff.staff_emails.create!(
      address: "contact-staff-#{SecureRandom.hex(4)}@example.com",
      staff_identity_email_status_id: StaffEmailStatus::VERIFIED,
    )
    staff.staff_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      staff_identity_telephone_status_id: StaffTelephoneStatus::VERIFIED,
    )

    context = Contact::ActorContext.new(actor: staff)

    assert_equal staff.staff_emails.first.address, context.email_address
    assert_equal staff.staff_telephones.first.number, context.telephone_number
    assert_equal staff.id, context.actor_id
    assert_equal "staff", context.actor_type
    assert_predicate context, :ready?
  end

  test "returns canonical customer contact details" do
    customer = create_verified_customer_with_email(email_address: "contact-customer-#{SecureRandom.hex(4)}@example.com")
    customer.customer_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
    )

    context = Contact::ActorContext.new(actor: customer)

    assert_equal customer.customer_emails.first.address, context.email_address
    assert_equal customer.customer_telephones.first.number, context.telephone_number
    assert_equal customer.id, context.actor_id
    assert_equal "customer", context.actor_type
    assert_predicate context, :ready?
  end

  test "ready? is false when a telephone is missing" do
    user = create_verified_user_with_email(email_address: "partial-#{SecureRandom.hex(4)}@example.com")

    context = Contact::ActorContext.new(actor: user)

    assert_equal user.user_emails.first.address, context.email_address
    assert_nil context.telephone_number
    assert_not_predicate context, :ready?
  end
end
