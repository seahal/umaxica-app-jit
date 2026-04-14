# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_categories
# Database name: publication
#
#  id                              :bigint           not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  app_timeline_category_master_id :bigint           default(0), not null
#  app_timeline_id                 :bigint           not null
#
# Indexes
#
#  idx_on_app_timeline_category_master_id_d1179f51ba  (app_timeline_category_master_id)
#  index_app_timeline_categories_unique               (app_timeline_id) UNIQUE
#
# Foreign Keys
#
#  fk_app_timeline_categories_on_app_timeline_category_master_id  (app_timeline_category_master_id => app_timeline_category_masters.id)
#  fk_rails_...                                                   (app_timeline_id => app_timelines.id) ON DELETE => cascade
#
#  fk_app_timeline_categories_on_app_timeline_category_master_id
#    (app_timeline_category_master_id => app_timeline_category_masters.id)
#  fk_rails_...
#    (app_timeline_id => app_timelines.id) ON DELETE => cascade
require "test_helper"

class AppTimelineCategoryTest < ActiveSupport::TestCase
  def setup
    @app_timeline = app_timelines(:one)
    @category_master = app_timeline_category_masters(:nothing)
  end

  test "is valid with app_timeline and category_master" do
    record = AppTimelineCategory.new(
      app_timeline: @app_timeline,
      app_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end

  test "requires app_timeline" do
    record = AppTimelineCategory.new(app_timeline_category_master: @category_master)

    assert_not record.valid?
    assert_not_empty record.errors[:app_timeline]
  end

  test "app_timeline must be unique" do
    AppTimelineCategory.create!(
      app_timeline: @app_timeline,
      app_timeline_category_master: @category_master,
    )

    duplicate = AppTimelineCategory.new(
      app_timeline: @app_timeline,
      app_timeline_category_master: @category_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:app_timeline_id]
  end

  test "different app_timeline with same category_master is allowed" do
    other_timeline = app_timelines(:two)
    record = AppTimelineCategory.new(
      app_timeline: other_timeline,
      app_timeline_category_master: @category_master,
    )

    assert_predicate record, :valid?
  end
end
