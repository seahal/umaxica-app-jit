# == Schema Information
#
# Table name: app_timelines
#
#  id                     :uuid             not null, primary key
#  app_timeline_status_id :string(255)      default(""), not null
#  created_at             :datetime         not null
#  description            :string           default(""), not null
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id              :string(21)       default(""), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_app_timelines_on_app_timeline_status_id  (app_timeline_status_id)
#  index_app_timelines_on_parent_id               (parent_id)
#  index_app_timelines_on_prev_id                 (prev_id)
#  index_app_timelines_on_public_id               (public_id)
#  index_app_timelines_on_staff_id                (staff_id)
#  index_app_timelines_on_succ_id                 (succ_id)
#

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

  test "app_timeline_status_id defaults to empty string" do
    timeline = AppTimeline.create!(title: "No Status Timeline")

    assert_equal "", timeline.app_timeline_status_id
    assert_nil timeline.app_timeline_status
  end
end
