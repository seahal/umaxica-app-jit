# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  org_timeline_category_master_id :bigint           default(0), not null
#  org_timeline_id                 :bigint           not null
#
# Indexes
#
#  idx_on_org_timeline_category_master_id_fa21cb5b0c  (org_timeline_category_master_id)
#  index_org_timeline_categories_unique               (org_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_org_timeline_categories_on_org_timeline_category_master_id  (org_timeline_category_master_id => org_timeline_category_masters.id)
#  fk_rails_...                                                   (org_timeline_id => org_timelines.id) ON DELETE => cascade
#
#  fk_org_timeline_categories_on_org_timeline_category_master_id
#    (org_timeline_category_master_id => org_timeline_category_masters.id)
#  fk_rails_...
#    (org_timeline_id => org_timelines.id) ON DELETE => cascade
require "test_helper"

class OrgTimelineCategoryTest < ActiveSupport::TestCase
  def setup
    @org_timeline = org_timelines(:one)
    @category_master = org_timeline_category_masters(:nothing)
  end

  test "is valid with org_timeline and category_master" do
    record = OrgTimelineCategory.new(
      org_timeline: @org_timeline,
      org_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "requires org_timeline" do
    record = OrgTimelineCategory.new(org_timeline_category_master: @category_master)

    assert_not record.valid?
    assert_not_empty record.errors[:org_timeline]
  end

  test "org_timeline must be unique" do
    OrgTimelineCategory.create!(
      org_timeline: @org_timeline,
      org_timeline_category_master: @category_master,
    )

    duplicate = OrgTimelineCategory.new(
      org_timeline: @org_timeline,
      org_timeline_category_master: @category_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:org_timeline_id]
  end

  test "different org_timeline with same category_master is allowed" do
    other_timeline = org_timelines(:two)
    record = OrgTimelineCategory.new(
      org_timeline: other_timeline,
      org_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end
end
