# typed: false
# frozen_string_literal: true

require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  fixtures :users, :staffs

  class MockRecord
    attr_accessor :user_id

    def initialize(user_id = nil)
      @user_id = user_id
    end
  end

  def test_index_with_staff_and_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { true }

    assert_predicate policy, :index?
  end

  def test_index_with_staff_without_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { false }

    assert_not policy.index?
  end

  def test_index_with_user
    user = users(:one)
    policy = UserPolicy.new(user, MockRecord.new)

    assert_not policy.index?
  end

  def test_index_with_nil_actor
    policy = UserPolicy.new(nil, MockRecord.new)

    assert_not policy.index?
  end

  def test_show_with_owner
    user = users(:one)
    record = MockRecord.new(user.id)
    policy = UserPolicy.new(user, record)

    assert_predicate policy, :show?
  end

  def test_show_with_staff_and_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { true }

    assert_predicate policy, :show?
  end

  def test_show_with_staff_without_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { false }

    assert_not policy.show?
  end

  def test_show_with_non_owner_user
    user = users(:one)
    other_user = users(:two)
    record = MockRecord.new(other_user.id)
    policy = UserPolicy.new(user, record)

    assert_not policy.show?
  end

  def test_create_with_staff_and_admin
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator?) { true }

    assert_predicate policy, :create?
  end

  def test_create_with_staff_without_admin
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator?) { false }

    assert_not policy.create?
  end

  def test_create_with_user
    user = users(:one)
    policy = UserPolicy.new(user, MockRecord.new)

    assert_not policy.create?
  end

  def test_update_with_owner
    user = users(:one)
    record = MockRecord.new(user.id)
    policy = UserPolicy.new(user, record)

    assert_predicate policy, :update?
  end

  def test_update_with_staff_and_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { true }

    assert_predicate policy, :update?
  end

  def test_update_with_staff_without_admin_or_manager
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator_or_manager?) { false }

    assert_not policy.update?
  end

  def test_update_with_non_owner_user
    user = users(:one)
    other_user = users(:two)
    record = MockRecord.new(other_user.id)
    policy = UserPolicy.new(user, record)

    assert_not policy.update?
  end

  def test_destroy_with_owner_user
    user = users(:one)
    record = MockRecord.new(user.id)
    policy = UserPolicy.new(user, record)

    assert_predicate policy, :destroy?
  end

  def test_destroy_with_staff_and_admin
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator?) { true }

    assert_predicate policy, :destroy?
  end

  def test_destroy_with_staff_without_admin
    staff = staffs(:one)
    policy = UserPolicy.new(staff, MockRecord.new)
    policy.define_singleton_method(:operator?) { false }

    assert_not policy.destroy?
  end

  def test_destroy_with_non_owner_user
    user = users(:one)
    other_user = users(:two)
    record = MockRecord.new(other_user.id)
    policy = UserPolicy.new(user, record)

    assert_not policy.destroy?
  end

  def test_new_delegates_to_create
    policy = UserPolicy.new(nil, MockRecord.new)

    assert_equal policy.send(:create?), policy.send(:new?)
  end

  def test_edit_delegates_to_update
    policy = UserPolicy.new(nil, MockRecord.new)

    assert_equal policy.send(:update?), policy.send(:edit?)
  end

  def test_scope_with_staff_admin_or_manager
    staff = staffs(:one)
    scope = UserPolicy::Scope.new(staff, User)
    scope.define_singleton_method(:operator_or_manager?) { true }

    assert_equal User.all, scope.resolve
  end

  def test_scope_with_staff_not_admin_or_manager
    staff = staffs(:one)
    scope = UserPolicy::Scope.new(staff, User)
    scope.define_singleton_method(:operator_or_manager?) { false }

    assert_equal User.none, scope.resolve
  end

  def test_scope_with_user
    user = users(:one)
    scope = UserPolicy::Scope.new(user, User)

    assert_equal User.where(id: user.id), scope.resolve
  end

  def test_scope_with_nil_actor
    scope = UserPolicy::Scope.new(nil, User)

    assert_equal User.none, scope.resolve
  end
end
