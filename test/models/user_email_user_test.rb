# frozen_string_literal: true

require "test_helper"

class UserEmailUserTest < ActiveSupport::TestCase
  test "the truth" do
    skip "TODO: replace with meaningful user email user test or remove"
  end

  test "email user relation" do
    ue = UserEmail.new(address: "one@example.com", confirm_policy: true)

    assert_predicate ue, :valid?
    assert ue.save
  end

  test "should inherit from IdentitiesRecord" do
    assert_operator UserEmailUser, :<, IdentitiesRecord
  end

  test "should belong to email with foreign key" do
    association = UserEmailUser.reflect_on_association(:email)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert association.options[:foreign_key]
  end

  test "should belong to user with foreign key" do
    association = UserEmailUser.reflect_on_association(:user)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
    assert association.options[:foreign_key]
  end

  test "should have inverse relationship with user_email_users" do
    email_association = UserEmailUser.reflect_on_association(:email)
    user_association = UserEmailUser.reflect_on_association(:user)

    assert_equal :user_email_users, email_association.options[:inverse_of]
    assert_equal :user_email_users, user_association.options[:inverse_of]
  end
end
