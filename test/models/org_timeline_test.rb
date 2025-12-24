# == Schema Information
#
# Table name: org_timelines
#
#  id                     :uuid             not null, primary key
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  description            :string           default(""), not null
#  org_timeline_status_id :string(255)      default("NONE"), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  public_id              :string(21)       default(""), not null
#
# Indexes
#
#  index_org_timelines_on_org_timeline_status_id  (org_timeline_status_id)
#  index_org_timelines_on_parent_id               (parent_id)
#  index_org_timelines_on_prev_id                 (prev_id)
#  index_org_timelines_on_public_id               (public_id)
#  index_org_timelines_on_staff_id                (staff_id)
#  index_org_timelines_on_succ_id                 (succ_id)
#

require "test_helper"

class OrgTimelineTest < ActiveSupport::TestCase
  fixtures :org_timeline_statuses

  def setup
    @status = org_timeline_statuses(:ACTIVE)
    @org_timeline = OrgTimeline.create!(
      title: "Test Timeline",
      description: "A test timeline",
      org_timeline_status: @status
    )
  end

  test "OrgTimeline class exists" do
    assert_kind_of Class, OrgTimeline
  end

  test "OrgTimeline inherits from BusinessesRecord" do
    assert_operator OrgTimeline, :<, BusinessesRecord
  end

  test "belongs to org_timeline_status" do
    association = OrgTimeline.reflect_on_association(:org_timeline_status)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with status" do
    assert_not_nil @org_timeline
    assert_equal @status.id, @org_timeline.org_timeline_status_id
  end

  test "org_timeline_status association loads status correctly" do
    assert_equal @status, @org_timeline.org_timeline_status
    assert_equal "ACTIVE", @org_timeline.org_timeline_status.id
  end

  test "includes Timeline module" do
    assert_includes OrgTimeline.included_modules, Timeline
  end

  test "org_timeline_status_id defaults to NONE" do
    timeline = OrgTimeline.create!(title: "No Status Timeline")

    assert_equal "NONE", timeline.org_timeline_status_id
    assert_nil timeline.org_timeline_status
  end
end
