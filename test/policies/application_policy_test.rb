require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  class TestRecord
    def initialize; end
  end

  class TestPolicy < ApplicationPolicy; end

  def setup
    @user = nil
    @record = TestRecord.new
    @policy = TestPolicy.new(@user, @record)
  end

  # Default behavior tests
  def test_index_returns_false_by_default
    assert_not @policy.send(:index?)
  end

  def test_show_returns_false_by_default
    assert_not @policy.send(:show?)
  end

  def test_create_returns_false_by_default
    assert_not @policy.send(:create?)
  end

  def test_new_delegates_to_create
    assert_equal @policy.send(:create?), @policy.send(:new?)
  end

  def test_update_returns_false_by_default
    assert_not @policy.send(:update?)
  end

  def test_edit_delegates_to_update
    assert_equal @policy.send(:update?), @policy.send(:edit?)
  end

  def test_destroy_returns_false_by_default
    assert_not @policy.send(:destroy?)
  end

  # Scope tests
  def test_scope_initialization
    scope_obj = ApplicationPolicy::Scope.new(@user, [])

    assert scope_obj
  end

  def test_scope_resolve_raises_not_implemented_error
    scope_obj = ApplicationPolicy::Scope.new(@user, [])
    assert_raises(NoMethodError) do
      scope_obj.resolve
    end
  end

  # Attributes tests
  def test_user_attribute_is_accessible
    policy = ApplicationPolicy.new(@user, @record)

    assert_nil policy.user
  end

  def test_record_attribute_is_accessible
    policy = ApplicationPolicy.new(@user, @record)

    assert_equal @record, policy.record
  end
end
