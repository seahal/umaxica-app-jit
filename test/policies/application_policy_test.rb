# frozen_string_literal: true

require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  def setup
    @user = "user"
    @record = "record"
    @policy = ApplicationPolicy.new(@user, @record)
  end

  test "index? should return false" do
    assert_not @policy.index?
  end

  test "show? should return false" do
    assert_not @policy.show?
  end

  test "create? should return false" do
    assert_not @policy.create?
  end

  test "new? should delegate to create?" do
    assert_equal @policy.create?, @policy.new?
  end

  test "update? should return false" do
    assert_not @policy.update?
  end

  test "edit? should delegate to update?" do
    assert_equal @policy.update?, @policy.edit?
  end

  test "destroy? should return false" do
    assert_not @policy.destroy?
  end

  test "should store user in instance variable" do
    assert_equal @user, @policy.user
  end

  test "should store record in instance variable" do
    assert_equal @record, @policy.record
  end

  class ScopeTest < ActiveSupport::TestCase
    def setup
      @user = "user"
      @scope = "scope"
      @policy_scope = ApplicationPolicy::Scope.new(@user, @scope)
    end

    test "resolve should raise NoMethodError" do
      assert_raises(NoMethodError) { @policy_scope.resolve }
    end

    test "should have access to user" do
      assert_equal @user, @policy_scope.send(:user)
    end

    test "should have access to scope" do
      assert_equal @scope, @policy_scope.send(:scope)
    end
  end
end
