# typed: false
# frozen_string_literal: true

require "test_helper"

class UnauthenticatedTest < ActiveSupport::TestCase
  test "instance returns self" do
    assert_same Unauthenticated, Unauthenticated.instance
  end

  test "id returns nil" do
    assert_nil Unauthenticated.id
  end

  test "user? returns false" do
    assert_not Unauthenticated.user?
  end

  test "customer? returns false" do
    assert_not Unauthenticated.customer?
  end

  test "staff? returns false" do
    assert_not Unauthenticated.staff?
  end

  test "unauthenticated? returns true" do
    assert_predicate Unauthenticated, :unauthenticated?
  end

  test "authenticated? returns false" do
    assert_not Unauthenticated.authenticated?
  end
end
