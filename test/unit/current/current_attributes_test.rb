# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentAttributesTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "reset clears all attributes" do
    user = users(:one)
    Current.actor = user
    Current.actor_type = :user
    Current.session = "session_123"
    Current.token = { "sub" => 1 }
    Current.domain = :app
    Current.preference = Current::Preference.new(language: "en")

    Current.reset

    assert_same Unauthenticated.instance, Current.actor
    assert_equal :unauthenticated, Current.actor_type
    assert_nil Current.session
    assert_nil Current.token
    assert_nil Current.domain
    assert_predicate Current.preference, :null?
  end

  test "user? and staff? reflect actor_type" do
    Current.actor_type = :staff

    assert_predicate Current, :staff?
    assert_not Current.user?
    assert_nil Current.user

    Current.actor_type = :user

    assert_predicate Current, :user?
    assert_not Current.staff?
    assert_nil Current.staff
  end

  test "user and staff return actor for matching actor_type" do
    user = users(:one)
    staff = staffs(:one)

    Current.actor = user
    Current.actor_type = :user

    assert_equal user, Current.user
    assert_nil Current.staff

    Current.actor = staff
    Current.actor_type = :staff

    assert_equal staff, Current.staff
    assert_nil Current.user
  end

  test "preference defaults to NULL" do
    assert_equal Current::Preference::NULL, Current.preference
    assert_predicate Current.preference, :null?
    assert_equal "ja", Current.preference.language
  end

  test "domain can be set" do
    Current.domain = :app

    assert_equal :app, Current.domain

    Current.domain = :org

    assert_equal :org, Current.domain
  end

  test "session can be set" do
    Current.session = "session_public_id"

    assert_equal "session_public_id", Current.session
  end

  test "token can be set" do
    payload = { "sub" => 42, "act" => "user" }
    Current.token = payload

    assert_equal payload, Current.token
  end

  test "actor accepts User instance" do
    user = users(:one)
    Current.actor = user

    assert_equal user, Current.actor
  end

  test "actor accepts Staff instance" do
    staff = staffs(:one)
    Current.actor = staff

    assert_equal staff, Current.actor
  end

  test "actor accepts Customer instance" do
    customer = create_verified_customer_with_email(email_address: "current-#{SecureRandom.hex(4)}@example.com")
    Current.actor = customer

    assert_equal customer, Current.actor
  ensure
    Current.reset
  end

  test "actor accepts Unauthenticated.instance" do
    Current.actor = Unauthenticated.instance

    assert_same Unauthenticated.instance, Current.actor
  end

  test "actor rejects string value" do
    assert_raises(ArgumentError) do
      Current.actor = "some_string"
    end
  end

  test "actor rejects symbol value" do
    assert_raises(ArgumentError) do
      Current.actor = :some_symbol
    end
  end

  test "actor rejects arbitrary object" do
    obj = Object.new
    assert_raises(ArgumentError) do
      Current.actor = obj
    end
  end

  test "actor rejects nil" do
    assert_raises(ArgumentError) do
      Current.actor = nil
    end
  end

  test "actor_type accepts :user" do
    Current.actor_type = :user

    assert_equal :user, Current.actor_type
  end

  test "actor_type accepts :staff" do
    Current.actor_type = :staff

    assert_equal :staff, Current.actor_type
  end

  test "actor_type accepts :customer" do
    Current.actor_type = :customer

    assert_equal :customer, Current.actor_type
  end

  test "actor_type accepts :unauthenticated" do
    Current.actor_type = :unauthenticated

    assert_equal :unauthenticated, Current.actor_type
  end

  test "actor_type rejects invalid symbol" do
    assert_raises(ArgumentError) do
      Current.actor_type = :invalid
    end
  end

  test "actor_type rejects string value" do
    assert_raises(ArgumentError) do
      Current.actor_type = "user"
    end
  end

  test "actor_type rejects nil" do
    assert_raises(ArgumentError) do
      Current.actor_type = nil
    end
  end
end
