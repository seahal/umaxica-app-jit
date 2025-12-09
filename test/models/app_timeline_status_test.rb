require "test_helper"

class AppTimelineStatusTest < ActiveSupport::TestCase
  fixtures :app_timeline_statuses

  def setup
    @status = app_timeline_statuses(:ACTIVE)
  end

  test "inherits from BusinessesRecord" do
    assert_operator AppTimelineStatus, :<, BusinessesRecord
  end

  test "has many app_timelines" do
    association = AppTimelineStatus.reflect_on_association(:app_timelines)

    assert_not_nil association
    assert_equal :has_many, association.macro
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

  test "has timestamps" do
    assert_not_nil @status.created_at
    assert_not_nil @status.updated_at
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
