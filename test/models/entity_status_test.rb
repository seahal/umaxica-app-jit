# == Schema Information
#
# Table name: entity_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class EntityStatusTest < ActiveSupport::TestCase
  test "the truth" do
    skip "TODO: replace with meaningful entity status test or remove"
  end

  test "should inherit from BusinessesRecord" do
    assert_operator EntityStatus, :<, BusinessesRecord
  end

  test "should create entity status with id" do
    status = EntityStatus.create(id: "active")

    assert_predicate status, :persisted?
    assert_equal "active", status.id
  end

  test "should find entity status by id" do
    status = EntityStatus.create(id: "pending")
    found_status = EntityStatus.find("pending")

    assert_equal "pending", found_status.id
  end

  test "should have created_at and updated_at" do
    status = EntityStatus.create(id: "test-status")

    assert_not_nil status.created_at
    assert_not_nil status.updated_at
  end
end
