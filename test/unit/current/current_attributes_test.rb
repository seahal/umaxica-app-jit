# typed: false
# frozen_string_literal: true

require "test_helper"

class CurrentAttributesTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "reset clears all attributes" do
    Current.actor = "some_user"
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
    user = Object.new
    staff = Object.new

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
    assert_equal "ja", Current.preference.language # Safe default
  end

  test "domain can be set" do
    Current.domain = :app

    assert_equal :app, Current.domain

    Current.domain = :org

    assert_equal :org, Current.domain
  end

  test "actor can be set" do
    Current.actor = "test_actor"

    assert_equal "test_actor", Current.actor
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
end
