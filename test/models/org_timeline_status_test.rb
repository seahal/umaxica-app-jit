# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_statuses
# Database name: news
#
#  id :integer          default(0), not null, primary key
#

require "test_helper"

class OrgTimelineStatusTest < ActiveSupport::TestCase
  def setup
    @model_class = OrgTimelineStatus
  end

  test "inherits from NewsRecord" do
    assert_operator OrgTimelineStatus, :<, NewsRecord
  end

  test "id is required" do
    status = @model_class.new(id: nil)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must be unique" do
    existing = @model_class.first!
    duplicate = @model_class.new(id: existing.id)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:id]
  end

  test "id must be a non-negative integer" do
    status = @model_class.new(id: -1)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "can find statuses by numeric id" do
    status = @model_class.find(0)

    assert_equal 0, status.id
  end
end
