# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  com_timeline_category_master_id :bigint           default(0), not null
#  com_timeline_id                 :bigint           not null
#
# Indexes
#
#  idx_on_com_timeline_category_master_id_3ab8427d3a  (com_timeline_category_master_id)
#  index_com_timeline_categories_unique               (com_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_com_timeline_categories_on_com_timeline_category_master_id  (com_timeline_category_master_id => com_timeline_category_masters.id)
#  fk_rails_...                                                   (com_timeline_id => com_timelines.id) ON DELETE => cascade
#
#  fk_com_timeline_categories_on_com_timeline_category_master_id
#    (com_timeline_category_master_id => com_timeline_category_masters.id)
#  fk_rails_...
#    (com_timeline_id => com_timelines.id) ON DELETE => cascade
require "test_helper"

class ComTimelineCategoryTest < ActiveSupport::TestCase
  def setup
    @com_timeline = com_timelines(:one)
    @category_master = com_timeline_category_masters(:nothing)
  end

  test "is valid with com_timeline and category_master" do
    record = ComTimelineCategory.new(
      com_timeline: @com_timeline,
      com_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "requires com_timeline" do
    record = ComTimelineCategory.new(com_timeline_category_master: @category_master)

    assert_not record.valid?
    assert_not_empty record.errors[:com_timeline]
  end

  test "com_timeline must be unique" do
    ComTimelineCategory.create!(
      com_timeline: @com_timeline,
      com_timeline_category_master: @category_master,
    )

    duplicate = ComTimelineCategory.new(
      com_timeline: @com_timeline,
      com_timeline_category_master: @category_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:com_timeline_id]
  end

  test "different com_timeline with same category_master is allowed" do
    other_timeline = com_timelines(:two)
    record = ComTimelineCategory.new(
      com_timeline: other_timeline,
      com_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end
end
