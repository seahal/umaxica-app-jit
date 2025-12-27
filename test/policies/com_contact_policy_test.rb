# frozen_string_literal: true

require "test_helper"

class ComContactPolicyTest < ActiveSupport::TestCase
  class MockContact
    def initialize
    end
  end

  def setup
    @user = nil
    @record = MockContact.new
    @policy = ComContactPolicy.new(@user, @record)
  end

  def test_policy_initializes_with_user_and_record
    policy = ComContactPolicy.new(@user, @record)

    assert_nil policy.user
    assert_equal @record, policy.record
  end

  def test_index
    # Staff can view
    staff = staffs(:one)
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:can_view?) { true }
    assert_predicate policy, :index?

    # Staff without view permission cannot view
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:can_view?) { false }
    assert_not policy.index?

    # User cannot view
    user = users(:one)
    policy = ComContactPolicy.new(user, @record)
    # create? is false by default for user in logic if not stubbed? No, index
    # logic: actor.is_a?(Staff) && can_view?
    # User is not Staff, so should be false regardless of can_view?
    policy.define_singleton_method(:can_view?) { true }
    assert_not policy.index?

    # Nil actor cannot view
    policy = ComContactPolicy.new(nil, @record)
    assert_not policy.index?
  end

  def test_show
    # Staff can view
    staff = staffs(:one)
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:can_view?) { true }
    assert_predicate policy, :show?

    # Staff without view permission cannot view (unless owner, but staff isn't owner here)
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:can_view?) { false }
    assert_not policy.show?

    # Owner user can view
    user = users(:one)
    record = OpenStruct.new(user_id: user.id)
    policy = ComContactPolicy.new(user, record)
    assert_predicate policy, :show?

    # Other user cannot view
    other_user = users(:two)
    policy = ComContactPolicy.new(other_user, record)
    # User is not Staff, so can_view? is not checked or doesn't matter for first clause.
    # Logic: (actor.is_a?(Staff) && can_view?) || owner?
    # User is not staff. Owner? is false.
    assert_not policy.show?
  end

  def test_create
    # Nil actor can create
    policy = ComContactPolicy.new(nil, @record)
    assert_predicate policy, :create?

    # User can create
    user = users(:one)
    policy = ComContactPolicy.new(user, @record)
    assert_predicate policy, :create?

    # Staff cannot create
    staff = staffs(:one)
    policy = ComContactPolicy.new(staff, @record)
    assert_not policy.create?
  end

  def test_update
    # Admin staff can update
    staff = staffs(:one) # assuming fixture one is admin/manager-like? We might need to mock admin_or_manager?
    # Helper to stub permissions helper since we don't know exact implementation
    # of admin_or_manager? in ApplicationPolicy or its mixins from just this file.
    # Looking at ApplicationPolicy would be good but usually we can stub.

    # Let's check ApplicationPolicy if we can or just stub methods on policy instance.
    # But usually we test policy logic.

    # Assuming standard roles, let's just stub the method on policy instance

    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:admin_or_manager?) { true }
    assert_predicate policy, :update?

    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:admin_or_manager?) { false }
    assert_not policy.update?

    # User cannot update
    user = users(:one)
    policy = ComContactPolicy.new(user, @record)
    assert_not policy.update?
  end

  def test_destroy
    staff = staffs(:one)

    # Admin can destroy
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:admin?) { true }
    assert_predicate policy, :destroy?

    # Non-admin cannot destroy
    policy = ComContactPolicy.new(staff, @record)
    policy.define_singleton_method(:admin?) { false }
    assert_not policy.destroy?
  end

  def test_scope
    # Staff manager sees all
    staff = staffs(:one)
    staff.define_singleton_method(:id) { 1 }

    # We need to stub ComContact.all and where probably or rely on actual AR if simple.
    # Since fixtures are loaded, we can rely on actual AR.

    scope_class = ComContactPolicy::Scope

    # Mocking behaviors on policy scope instance or passing stubbed actors

    # Case 1: Staff Manager
    # We need to stub admin_or_manager? on the policy scope instance which wraps the actor?
    # No, admin_or_manager? comes from ApplicationPolicy::Scope or a mixin included there.
    # Let's see ComContactPolicy::Scope inherits from ApplicationPolicy::Scope.

    # Let's just create a test subclass for scope testing to inject behaviors if needed,
    # or rely on what we know about staffs fixture.

    # Assuming we can stub methods on the scope instance after creation? No, resolve is called immediately usually?
    # Actually resolve is a method.

    policy_scope = scope_class.new(staff, ComContact)
    policy_scope.define_singleton_method(:admin_or_manager?) { true }
    assert_equal ComContact.all, policy_scope.resolve

    # Case 2: Regular Staff
    policy_scope = scope_class.new(staff, ComContact)
    policy_scope.define_singleton_method(:admin_or_manager?) { false }
    # Should be where(staff_id: [actor.id, nil])
    expected = ComContact.where(staff_id: [staff.id, nil])
    assert_equal expected, policy_scope.resolve

    # Case 3: User
    user = users(:one)
    policy_scope = scope_class.new(user, ComContact)
    expected = ComContact.where(user_id: user.id)
    assert_equal expected, policy_scope.resolve

    # Case 4: Nil
    policy_scope = scope_class.new(nil, ComContact)
    assert_equal ComContact.none, policy_scope.resolve
  end
end
