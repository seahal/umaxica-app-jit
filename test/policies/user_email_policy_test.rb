<<<<<<<< HEAD:test/policies/staff_passkey_policy_test.rb
========
# typed: false
>>>>>>>> develop:test/policies/user_email_policy_test.rb
# frozen_string_literal: true

require "test_helper"

<<<<<<<< HEAD:test/policies/staff_passkey_policy_test.rb
class StaffPasskeyPolicyTest < ActiveSupport::TestCase
  def setup
    @user = nil
    @record = nil
    @policy = StaffPasskeyPolicy.new(@user, @record)
========
class UserEmailPolicyTest < ActiveSupport::TestCase
  def setup
    @user = nil
    @record = nil
    @policy = UserEmailPolicy.new(@user, @record)
>>>>>>>> develop:test/policies/user_email_policy_test.rb
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
<<<<<<<< HEAD:test/policies/staff_passkey_policy_test.rb
    scope = StaffPasskeyPolicy::Scope.new(@user, nil)
========
    scope = UserEmailPolicy::Scope.new(@user, nil)
>>>>>>>> develop:test/policies/user_email_policy_test.rb
    assert_raises(NoMethodError) { scope.resolve }
  end
end
