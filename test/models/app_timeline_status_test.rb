# == Schema Information
#
# Table name: app_timeline_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

require "test_helper"

class AppTimelineStatusTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  fixtures :app_timeline_statuses

  def setup
    @status = app_timeline_statuses(:ACTIVE)
    @model_class = AppTimelineStatus
  end

  test "inherits from BusinessesRecord" do
    assert_operator AppTimelineStatus, :<, BusinessesRecord
  end

  test "id is required" do
    status = AppTimelineStatus.new(id: nil)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must be unique" do
    status = AppTimelineStatus.new(id: "ACTIVE")

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id must have maximum length of 255" do
    status = AppTimelineStatus.new(id: "A" * 256)

    assert_not status.valid?
    assert_not_empty status.errors[:id]
  end

  test "id can have maximum length of 255" do
    long_id = "A" * 255
    status = AppTimelineStatus.create!(id: long_id)

    assert_predicate status, :valid?
    assert_equal 255, status.id.length
  end

  test "can load draft status from fixtures" do
    draft = app_timeline_statuses(:DRAFT)

    assert_not_nil draft
    assert_equal "DRAFT", draft.id
  end

  test "can load archived status from fixtures" do
    archived = app_timeline_statuses(:ARCHIVED)

    assert_not_nil archived
    assert_equal "ARCHIVED", archived.id
  end
end
