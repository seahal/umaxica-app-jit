# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

require "test_helper"

class ComTimelineStatusTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  fixtures :com_timeline_statuses

  def setup
    @model_class = ComTimelineStatus
    @valid_id = "ACTIVE"
    @subject = @model_class.new(id: @valid_id)
    @status = com_timeline_statuses(:ACTIVE)
  end

  test "inherits from BusinessesRecord" do
    assert_operator ComTimelineStatus, :<, TimelineRecord
  end

  test "id is required" do
    status = ComTimelineStatus.new(id: nil)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must be unique" do
    status = ComTimelineStatus.new(id: "ACTIVE")

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must have maximum length of 255" do
    status = ComTimelineStatus.new(id: "A" * 256)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id can have maximum length of 255" do
    long_id = "A" * 255
    status = ComTimelineStatus.create!(id: long_id)

    assert_predicate status, :valid?
    assert_equal 255, status.id.length
  end

  test "can load draft status from fixtures" do
    draft = com_timeline_statuses(:DRAFT)

    assert_not_nil draft
    assert_equal "DRAFT", draft.id
  end

  test "can load archived status from fixtures" do
    archived = com_timeline_statuses(:ARCHIVED)

    assert_not_nil archived
    assert_equal "ARCHIVED", archived.id
  end
end
