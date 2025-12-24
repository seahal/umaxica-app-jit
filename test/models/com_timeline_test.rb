# == Schema Information
#
# Table name: com_timelines
#
#  id                     :uuid             not null, primary key
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  description            :string           default(""), not null
#  com_timeline_status_id :string(255)      default("NONE"), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  public_id              :string(21)       default(""), not null
#
# Indexes
#
#  index_com_timelines_on_com_timeline_status_id  (com_timeline_status_id)
#  index_com_timelines_on_parent_id               (parent_id)
#  index_com_timelines_on_prev_id                 (prev_id)
#  index_com_timelines_on_public_id               (public_id)
#  index_com_timelines_on_staff_id                (staff_id)
#  index_com_timelines_on_succ_id                 (succ_id)
#

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

  test "com_timeline_status_id defaults to NONE" do
    timeline = ComTimeline.create!(title: "No Status Timeline")

    assert_equal "NONE", timeline.com_timeline_status_id
    assert_nil timeline.com_timeline_status
  end
end
