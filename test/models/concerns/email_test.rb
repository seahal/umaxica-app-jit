# frozen_string_literal: true

require "test_helper"

# Test with UserIdentityEmail which includes Email
class EmailTest < ActiveSupport::TestCase
  test "concern can be included in a class" do
    assert_includes UserIdentityEmail.included_modules, Email
  end

  test "concern adds confirm_policy accessor" do
    email = UserIdentityEmail.new

    assert_respond_to email, :confirm_policy
    assert_respond_to email, :confirm_policy=
  end

  test "concern adds pass_code accessor" do
    email = UserIdentityEmail.new

    assert_respond_to email, :pass_code
    assert_respond_to email, :pass_code=
  end

  test "downcases address before save" do
    email = UserIdentityEmail.new(address: "TEST@EXAMPLE.COM", confirm_policy: true)
    email.save!

    assert_equal "test@example.com", email.address
  end

  test "encrypts address deterministically" do
    email1 = UserIdentityEmail.create!(address: "test1@example.com", confirm_policy: true)
    email2 = UserIdentityEmail.create!(address: "test2@example.com", confirm_policy: true)

    # Different emails should have different encrypted values
    raw1 = UserIdentityEmail.connection.execute("SELECT address FROM user_identity_emails WHERE id = '#{email1.id}'").first
    raw2 = UserIdentityEmail.connection.execute("SELECT address FROM user_identity_emails WHERE id = '#{email2.id}'").first

    assert_not_equal raw1["address"], raw2["address"]
  end

  test "validates email format" do
    # Valid emails
    assert_predicate UserIdentityEmail.new(address: "test@example.com", confirm_policy: true), :valid?
    assert_predicate UserIdentityEmail.new(address: "user+tag@example.co.jp", confirm_policy: true), :valid?

    # Invalid email
    assert_not UserIdentityEmail.new(address: "invalid-email", confirm_policy: true).valid?
  end

  test "validates email presence" do
    email = UserIdentityEmail.new(address: nil, confirm_policy: true)

    assert_not email.valid?
    assert_predicate email.errors[:address], :any?
  end

  test "validates uniqueness of address case insensitively" do
    UserIdentityEmail.create!(address: "test@example.com", confirm_policy: true)
    duplicate = UserIdentityEmail.new(address: "TEST@EXAMPLE.COM", confirm_policy: true)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:address], :any?
  end

  test "validates confirm_policy acceptance" do
    email = UserIdentityEmail.new(address: "test@example.com", confirm_policy: false)

    assert_not email.valid?
    assert_predicate email.errors[:confirm_policy], :any?
  end
end
