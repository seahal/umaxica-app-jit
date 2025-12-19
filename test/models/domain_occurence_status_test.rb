require "test_helper"

class DomainOccurenceStatusTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  fixtures :domain_occurence_statuses

  def setup
    @model_class = DomainOccurenceStatus
    @status = domain_occurence_statuses(:ACTIVE)
  end

  test "inherits from UniversalRecord" do
    assert_operator DomainOccurenceStatus, :<, UniversalRecord
  end

  test "has many domain_occurences" do
    association = DomainOccurenceStatus.reflect_on_association(:domain_occurences)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "defines NONE constant" do
    assert_equal "NONE", DomainOccurenceStatus::NONE
  end

  test "defines ACTIVE constant" do
    assert_equal "ACTIVE", DomainOccurenceStatus::ACTIVE
  end

  test "defines INACTIVE constant" do
    assert_equal "INACTIVE", DomainOccurenceStatus::INACTIVE
  end

  test "defines BLOCKED constant" do
    assert_equal "BLOCKED", DomainOccurenceStatus::BLOCKED
  end

  test "can load NONE status from fixtures" do
    none = domain_occurence_statuses(:NONE)

    assert_not_nil none
    assert_equal "NONE", none.id
  end

  test "can load ACTIVE status from fixtures" do
    active = domain_occurence_statuses(:ACTIVE)

    assert_not_nil active
    assert_equal "ACTIVE", active.id
  end

  test "can load INACTIVE status from fixtures" do
    inactive = domain_occurence_statuses(:INACTIVE)

    assert_not_nil inactive
    assert_equal "INACTIVE", inactive.id
  end

  test "can load BLOCKED status from fixtures" do
    blocked = domain_occurence_statuses(:BLOCKED)

    assert_not_nil blocked
    assert_equal "BLOCKED", blocked.id
  end
end
