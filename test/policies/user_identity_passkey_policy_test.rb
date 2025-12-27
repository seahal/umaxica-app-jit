# frozen_string_literal: true

require "test_helper"

class UserIdentityPasskeyPolicyTest < ActiveSupport::TestCase
  def setup
    @user = nil
    @record = nil
    @policy = UserIdentityPasskeyPolicy.new(@user, @record)
  end

  def test_index
    assert_not @policy.index?
  end

  def test_show
    assert_not @policy.show?
  end

  def test_create
    assert_not @policy.create?
  end

  def test_new
    assert_not @policy.new?
  end

  def test_update
    assert_not @policy.update?
  end

  def test_edit
    assert_not @policy.edit?
  end

  def test_destroy
    assert_not @policy.destroy?
  end

  def test_scope
    scope = UserIdentityPasskeyPolicy::Scope.new(@user, nil)
    assert_raises(NoMethodError) { scope.resolve }
  end
end
