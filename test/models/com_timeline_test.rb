require "test_helper"

class ComTimelineTest < ActiveSupport::TestCase
  fixtures :com_timeline_statuses

  def setup
    @status = com_timeline_statuses(:ACTIVE)
    @com_timeline = ComTimeline.create!(
      title: "Test Timeline",
      description: "A test timeline",
      com_timeline_status: @status
    )
  end

  test "ComTimeline class exists" do
    assert_kind_of Class, ComTimeline
  end

  test "ComTimeline inherits from BusinessesRecord" do
    assert_operator ComTimeline, :<, BusinessesRecord
  end

  test "belongs to com_timeline_status" do
    association = ComTimeline.reflect_on_association(:com_timeline_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @com_timeline
    assert_equal @status.id, @com_timeline.com_timeline_status_id
  end

  test "com_timeline_status association loads status correctly" do
    assert_equal @status, @com_timeline.com_timeline_status
    assert_equal "ACTIVE", @com_timeline.com_timeline_status.id
  end

  test "includes Timeline module" do
    assert_includes ComTimeline.included_modules, Timeline
  end

  test "com_timeline_status_id can be nil" do
    timeline = ComTimeline.create!(title: "No Status Timeline")

    assert_nil timeline.com_timeline_status_id
    assert_nil timeline.com_timeline_status
  end
end
