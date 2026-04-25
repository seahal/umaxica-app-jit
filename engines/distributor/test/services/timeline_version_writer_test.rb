# typed: false
# frozen_string_literal: true

require "test_helper"

class TimelineVersionWriterTest < ActiveSupport::TestCase
  fixtures :com_timelines, :com_timeline_statuses,
           :app_timelines, :app_timeline_statuses,
           :org_timelines, :org_timeline_statuses,
           :users, :staffs

  test "writes com timeline version" do
    timeline = com_timelines(:one)

    version = nil
    assert_difference "ComTimelineVersion.count", 1 do
      version = TimelineVersionWriter.write!(
        timeline,
        attrs: { title: "Title",
                 description: "Desc",
                 body: "Body",
                 permalink: "test-permalink", },
      )
    end

    assert_equal timeline, version.com_timeline
    assert_equal "Title", version.title
    assert_equal "Desc", version.description
    assert_equal "Body", version.body
  end

  test "writes app timeline version" do
    timeline = app_timelines(:one)

    version = nil
    assert_difference "AppTimelineVersion.count", 1 do
      version = TimelineVersionWriter.write!(
        timeline,
        attrs: { title: "Title",
                 description: "Desc",
                 body: "Body",
                 permalink: "test-permalink", },
      )
    end

    assert_equal timeline, version.app_timeline
    assert_equal "Title", version.title
  end

  test "writes org timeline version" do
    timeline = org_timelines(:one)

    version = nil
    assert_difference "OrgTimelineVersion.count", 1 do
      version = TimelineVersionWriter.write!(
        timeline,
        attrs: { title: "Title",
                 description: "Desc",
                 body: "Body",
                 permalink: "test-permalink", },
      )
    end

    assert_equal timeline, version.org_timeline
    assert_equal "Title", version.title
  end

  test "raises ArgumentError for unsupported timeline type" do
    unsupported_timeline = Struct.new(:class).new(Class.new)

    assert_raises(ArgumentError) do
      TimelineVersionWriter.write!(
        unsupported_timeline,
        attrs: { title: "Title",
                 description: "Desc",
                 body: "Body",
                 permalink: "test-permalink", },
      )
    end
  end

  test "writes version with user editor" do
    timeline = com_timelines(:one)
    user = users(:one)

    version = TimelineVersionWriter.write!(
      timeline,
      attrs: { title: "Title",
               description: "Desc",
               body: "Body",
               permalink: "test-permalink", },
      editor: user,
    )

    assert_equal "User", version.edited_by_type
    assert_equal user.id, version.edited_by_id
  end

  test "writes version with staff editor" do
    timeline = com_timelines(:one)
    staff = staffs(:one)

    version = TimelineVersionWriter.write!(
      timeline,
      attrs: { title: "Title",
               description: "Desc",
               body: "Body",
               permalink: "test-permalink", },
      editor: staff,
    )

    assert_equal "Staff", version.edited_by_type
    assert_equal staff.id, version.edited_by_id
  end

  test "writes version with nil editor" do
    timeline = com_timelines(:one)

    version = TimelineVersionWriter.write!(
      timeline,
      attrs: { title: "Title",
               description: "Desc",
               body: "Body",
               permalink: "test-permalink", },
      editor: nil,
    )

    assert_nil version.edited_by_type
    assert_nil version.edited_by_id
  end
end
