# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  com_timeline_id            :bigint           not null
#  com_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_com_timeline_tags_on_master_and_timeline  (com_timeline_tag_master_id,com_timeline_id) UNIQUE
#  index_com_timeline_tags_on_com_timeline_id    (com_timeline_id)
#
# Foreign Keys
#
#  fk_com_timeline_tags_on_com_timeline_tag_master_id  (com_timeline_tag_master_id => com_timeline_tag_masters.id)
#  fk_rails_...                                        (com_timeline_id => com_timelines.id) ON DELETE => cascade
#
require "test_helper"

class ComTimelineTagTest < ActiveSupport::TestCase
  def setup
    @com_timeline = com_timelines(:one)
    @tag_master = com_timeline_tag_masters(:nothing)
  end

  test "is valid with com_timeline and tag_master" do
    record = ComTimelineTag.new(
      com_timeline: @com_timeline,
      com_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires com_timeline" do
    record = ComTimelineTag.new(com_timeline_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:com_timeline]
  end

  test "com_timeline and tag_master combination must be unique" do
    ComTimelineTag.create!(
      com_timeline: @com_timeline,
      com_timeline_tag_master: @tag_master,
    )

    duplicate = ComTimelineTag.new(
      com_timeline: @com_timeline,
      com_timeline_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:com_timeline_tag_master_id]
  end

  test "different com_timeline with same tag_master is allowed" do
    other_timeline = com_timelines(:two)
    record = ComTimelineTag.new(
      com_timeline: other_timeline,
      com_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
