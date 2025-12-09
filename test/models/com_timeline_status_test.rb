require "test_helper"

class ComTimelineStatusTest < ActiveSupport::TestCase
  fixtures :com_timeline_statuses

  def setup
    @status = com_timeline_statuses(:ACTIVE)
  end

  test "inherits from BusinessesRecord" do
    assert_operator ComTimelineStatus, :<, BusinessesRecord
  end

  test "has many com_timelines" do
    association = ComTimelineStatus.reflect_on_association(:com_timelines)

    assert_not_nil association
    assert_equal :has_many, association.macro
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

  test "has timestamps" do
    assert_not_nil @status.created_at
    assert_not_nil @status.updated_at
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
