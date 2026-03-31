# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "defaults actor to unauthenticated" do
    Current.reset

    assert_same Unauthenticated.instance, Current.actor
    assert_predicate Current, :unauthenticated?
    assert_not_predicate Current, :authenticated?
    assert_equal :unauthenticated, Current.actor_type
  end

  test "recognizes customer actor type" do
    customer = create_verified_customer_with_email(email_address: "current-#{SecureRandom.hex(4)}@example.com")

    Current.actor = customer
    Current.actor_type = :customer

    assert_predicate Current, :customer?
    assert_equal customer, Current.customer
    assert_predicate Current, :authenticated?
  ensure
    Current.reset
  end
end
