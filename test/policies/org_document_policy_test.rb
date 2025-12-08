# frozen_string_literal: true

require "test_helper"

class OrgDocumentPolicyTest < ActiveSupport::TestCase
  class MockDocument; end

  def setup
    @user = nil
    @record = MockDocument.new
    @policy = OrgDocumentPolicy.new(@user, @record)
  end

  def test_policy_initializes_with_user_and_record
    policy = OrgDocumentPolicy.new(@user, @record)

    assert_nil policy.user
    assert_equal @record, policy.record
  end

  def test_index_returns_false_by_default
    assert_not @policy.send(:index?)
  end

  def test_show_returns_false_by_default
    assert_not @policy.send(:show?)
  end

  def test_create_returns_false_by_default
    assert_not @policy.send(:create?)
  end

  def test_update_returns_false_by_default
    assert_not @policy.send(:update?)
  end

  def test_destroy_returns_false_by_default
    assert_not @policy.send(:destroy?)
  end

  def test_scope_initializes_without_error
    scope = OrgDocumentPolicy::Scope.new(@user, OrgDocument)

    assert scope
  end
end
