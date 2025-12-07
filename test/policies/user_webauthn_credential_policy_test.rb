# frozen_string_literal: true

require "test_helper"

class UserWebauthnCredentialPolicyTest < ActiveSupport::TestCase
  class MockCredential
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end
  end

  def setup
    @user = users(:one)
    @other_user = users(:two)
    @credential = MockCredential.new(@user.id)
    @other_credential = MockCredential.new(@other_user.id)
    @policy = UserWebauthnCredentialPolicy.new(@user, @credential)
    @other_policy = UserWebauthnCredentialPolicy.new(@other_user, @credential)
end

  test "user can view their own credentials" do
    assert_predicate @policy, :show?
  end

  test "user cannot view other users credentials" do
    assert_not @other_policy.show?
  end

  test "user can list their credentials" do
    assert_predicate @policy, :index?
  end

  test "unauthenticated user cannot list credentials" do
    policy = UserWebauthnCredentialPolicy.new(nil, @credential)

    assert_not policy.index?
  end

  test "user can create credentials" do
    assert_predicate @policy, :create?
  end

  test "unauthenticated user cannot create credentials" do
    policy = UserWebauthnCredentialPolicy.new(nil, @credential)

    assert_not policy.create?
  end

  test "user can delete their own credentials" do
    assert_predicate @policy, :destroy?
  end

  test "user cannot delete other users credentials" do
    assert_not @other_policy.destroy?
  end

  test "user can update their own credentials" do
    assert_predicate @policy, :update?
  end

  test "user cannot update other users credentials" do
    assert_not @other_policy.update?
  end
end
