require "test_helper"

class AppTimelineTest < ActiveSupport::TestCase
  fixtures :app_timeline_statuses

  def setup
    @status = app_timeline_statuses(:ACTIVE)
    @app_timeline = AppTimeline.create!(
      title: "Test Timeline",
      description: "A test timeline",
      app_timeline_status: @status
    )
  end

  test "AppTimeline class exists" do
    assert_kind_of Class, AppTimeline
  end

  test "AppTimeline inherits from BusinessesRecord" do
    assert_operator AppTimeline, :<, BusinessesRecord
  end

  test "belongs to app_timeline_status" do
    association = AppTimeline.reflect_on_association(:app_timeline_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @app_timeline
    assert_equal @status.id, @app_timeline.app_timeline_status_id
  end

  test "app_timeline_status association loads status correctly" do
    assert_equal @status, @app_timeline.app_timeline_status
    assert_equal "ACTIVE", @app_timeline.app_timeline_status.id
  end

  test "includes Timeline module" do
    assert_includes AppTimeline.included_modules, Timeline
  end

  test "app_timeline_status_id can be nil" do
    timeline = AppTimeline.create!(title: "No Status Timeline")

    assert_nil timeline.app_timeline_status_id
    assert_nil timeline.app_timeline_status
  end
end
