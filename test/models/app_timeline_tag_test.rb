# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_tags
# Database name: publication
#
#  id                         :bigint           not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  app_timeline_id            :bigint           not null
#  app_timeline_tag_master_id :bigint           default(0), not null
#
# Indexes
#
#  idx_app_timeline_tags_on_master_and_timeline  (app_timeline_tag_master_id,app_timeline_id) UNIQUE
#  index_app_timeline_tags_on_app_timeline_id    (app_timeline_id)
#
# Foreign Keys
#
#  fk_app_timeline_tags_on_app_timeline_tag_master_id  (app_timeline_tag_master_id => app_timeline_tag_masters.id)
#  fk_rails_...                                        (app_timeline_id => app_timelines.id) ON DELETE => cascade
#
require "test_helper"

class AppTimelineTagTest < ActiveSupport::TestCase
  def setup
    @app_timeline = app_timelines(:one)
    @tag_master = app_timeline_tag_masters(:nothing)
  end

  test "is valid with app_timeline and tag_master" do
    record = AppTimelineTag.new(
      app_timeline: @app_timeline,
      app_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end

  test "requires app_timeline" do
    record = AppTimelineTag.new(app_timeline_tag_master: @tag_master)

    assert_not record.valid?
    assert_not_empty record.errors[:app_timeline]
  end

  test "app_timeline and tag_master combination must be unique" do
    AppTimelineTag.create!(
      app_timeline: @app_timeline,
      app_timeline_tag_master: @tag_master,
    )

    duplicate = AppTimelineTag.new(
      app_timeline: @app_timeline,
      app_timeline_tag_master: @tag_master,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:app_timeline_tag_master_id]
  end

  test "different app_timeline with same tag_master is allowed" do
    other_timeline = app_timelines(:two)
    record = AppTimelineTag.new(
      app_timeline: other_timeline,
      app_timeline_tag_master: @tag_master,
    )

    assert_predicate record, :valid?
  end
end
