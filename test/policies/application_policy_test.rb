require "test_helper"


class ApplicationPolicyTest < ActiveSupport::TestCase
  DummyRecord = Struct.new(:id)

  def setup
    @user = Object.new
    @record = DummyRecord.new(1)
    @policy = ApplicationPolicy.new(@user, @record)
  end

  # rubocop:disable Minitest/MultipleAssertions
  def test_default_permissions_are_denied
    assert_not_predicate @policy, :index?
    assert_not_predicate @policy, :show?
    assert_not_predicate @policy, :create?
    assert_not_predicate @policy, :update?
    assert_not_predicate @policy, :destroy?
  end
  # rubocop:enable Minitest/MultipleAssertions

  def test_new_and_edit_delegate_to_create_and_update
    # new? delegates to create?
    assert_equal @policy.create?, @policy.new?
    # edit? delegates to update?
    assert_equal @policy.update?, @policy.edit?
  end

  def test_scope_requires_resolve_implementation
    scope = ApplicationPolicy::Scope.new(@user, DummyRecord)
    error = assert_raises(NoMethodError) { scope.resolve }
    assert_match(/You must define #resolve/, error.message)
  end
end
