# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  org_timeline_id            :bigint           not null
#  org_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_org_timeline_tags_on_master_and_timeline  (org_timeline_tag_master_id,org_timeline_id) UNIQUE
#  index_org_timeline_tags_on_org_timeline_id    (org_timeline_id)
#
# Foreign Keys
#
#  fk_org_timeline_tags_on_org_timeline_tag_master_id  (org_timeline_tag_master_id => org_timeline_tag_masters.id)
#  fk_rails_...                                        (org_timeline_id => org_timelines.id) ON DELETE => cascade
#
require "test_helper"

class OrgTimelineTagTest < ActiveSupport::TestCase
  def setup
    @org_timeline = org_timelines(:one)
    @tag_master = org_timeline_tag_masters(:nothing)
  end

  test "is valid with org_timeline and tag_master" do
    record = OrgTimelineTag.new(
      org_timeline: @org_timeline,
      org_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires org_timeline" do
    record = OrgTimelineTag.new(org_timeline_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:org_timeline]
  end

  test "org_timeline and tag_master combination must be unique" do
    OrgTimelineTag.create!(
      org_timeline: @org_timeline,
      org_timeline_tag_master: @tag_master,
    )

    duplicate = OrgTimelineTag.new(
      org_timeline: @org_timeline,
      org_timeline_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:org_timeline_tag_master_id]
  end

  test "different org_timeline with same tag_master is allowed" do
    other_timeline = org_timelines(:two)
    record = OrgTimelineTag.new(
      org_timeline: other_timeline,
      org_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
