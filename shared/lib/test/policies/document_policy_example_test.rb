# typed: false
# frozen_string_literal: true

require "test_helper"

class DocumentPolicyExampleTest < ActiveSupport::TestCase
  class MockRecord
    attr_accessor :user_id, :organization_id

    def initialize(user_id: nil, organization_id: nil)
      @user_id = user_id
      @organization_id = organization_id
    end
  end

  class MockUser
    attr_reader :id

    def initialize(id: 1, verified: true)
      @id = id
      @verified = verified
    end

    def verified?
      @verified
    end

    def has_role?(*, **)
      false
    end

    def is_a?(klass)
      klass.name == "User"
    end
  end

  class MockStaff
    attr_reader :id

    def initialize(id: 1, roles: {})
      @id = id
      @roles = roles
    end

    def has_role?(role, organization:)
      @roles[organization.to_i] == role
    end

    def is_a?(klass)
      klass.name == "Staff"
    end
  end

  def setup
    @user = MockUser.new(id: 1)
    @staff = MockStaff.new(id: 1, roles: { 1 => "viewer" })
    @staff_editor = MockStaff.new(id: 2, roles: { 1 => "editor" })
    @staff_operator = MockStaff.new(id: 3, roles: { 1 => "operator" })
    @record = MockRecord.new(user_id: 1, organization_id: 1)
  end

  def test_index_returns_false_by_default_for_unauthenticated
    policy = DocumentPolicyExample.new(nil, @record)

    assert_not policy.index?
  end

  def test_show_returns_true_for_owner
    policy = DocumentPolicyExample.new(@user, @record)

    assert_predicate policy, :show?
  end

  def test_show_returns_false_for_non_owner_without_scope
    other_user = MockUser.new(id: 99)
    policy = DocumentPolicyExample.new(other_user, @record)

    assert_not policy.show?
  end

  def test_create_returns_false_without_write_scope
    policy = DocumentPolicyExample.new(@user, @record)

    assert_not policy.create?
  end

  def test_update_returns_true_for_owner
    policy = DocumentPolicyExample.new(@user, @record)

    assert_predicate policy, :update?
  end

  def test_update_returns_false_for_non_owner_without_scope
    other_user = MockUser.new(id: 99)
    policy = DocumentPolicyExample.new(other_user, @record)

    assert_not policy.update?
  end

  def test_destroy_returns_true_for_owner
    policy = DocumentPolicyExample.new(@user, @record)

    assert_predicate policy, :destroy?
  end

  def test_destroy_returns_false_for_non_owner_without_admin_scope
    other_user = MockUser.new(id: 99)
    policy = DocumentPolicyExample.new(other_user, @record)

    assert_not policy.destroy?
  end

  class MockScope
    attr_reader :actor

    def initialize(actor)
      @actor = actor
    end

    def all
      [:all_records]
    end

    def none
      []
    end

    def where(*)
      [:filtered_records]
    end
  end

  def test_scope_resolve_with_read_all_scope
    scope = DocumentPolicyExample::Scope.new(MockUser.new(id: 1), MockScope.new(nil))

    assert_not_nil scope
  end

  def test_scope_resolve_with_no_actor
    scope = DocumentPolicyExample::Scope.new(nil, MockScope.new(nil))

    assert_not_nil scope
  end
end
