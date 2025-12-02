# == Schema Information
#
# Table name: timelines
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
require "test_helper"

class TimelineTest < ActiveSupport::TestCase
  test "should inherit from BusinessesRecord" do
    assert_operator Timeline, :<, BusinessesRecord
  end

  test "should create timeline with title and description" do
    timeline = Timeline.create(title: "Test Timeline", description: "Test Description")

    assert_predicate timeline, :persisted?
    assert_equal "Test Timeline", timeline.title
    assert_equal "Test Description", timeline.description
  end

  test "should have uuid as primary key" do
    timeline = Timeline.create(title: "Test")

    assert_kind_of String, timeline.id
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, timeline.id)
  end

  test "should allow nil title" do
    timeline = Timeline.create(title: nil, description: "Description")

    assert_predicate timeline, :persisted?
  end

  test "should allow nil description" do
    timeline = Timeline.create(title: "Title", description: nil)

    assert_predicate timeline, :persisted?
  end

  test "should update title" do
    timeline = Timeline.create(title: "Original")
    timeline.update(title: "Updated")

    assert_equal "Updated", timeline.reload.title
  end

  test "should update description" do
    timeline = Timeline.create(description: "Original")
    timeline.update(description: "Updated")

    assert_equal "Updated", timeline.reload.description
  end
end
