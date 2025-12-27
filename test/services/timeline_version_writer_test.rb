# frozen_string_literal: true

require "test_helper"

class TimelineVersionWriterTest < ActiveSupport::TestCase
  test "writes com timeline version" do
    timeline = com_timelines(:one)

    version = nil
    assert_difference "ComTimelineVersion.count", 1 do
      version = TimelineVersionWriter.write!(timeline, attrs: { title: "Title", description: "Desc", body: "Body" })
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
      version = TimelineVersionWriter.write!(timeline, attrs: { title: "Title", description: "Desc", body: "Body" })
    end

    assert_equal timeline, version.app_timeline
    assert_equal "Title", version.title
  end

  test "writes org timeline version" do
    timeline = org_timelines(:one)

    version = nil
    assert_difference "OrgTimelineVersion.count", 1 do
      version = TimelineVersionWriter.write!(timeline, attrs: { title: "Title", description: "Desc", body: "Body" })
    end

    assert_equal timeline, version.org_timeline
    assert_equal "Title", version.title
  end
end
