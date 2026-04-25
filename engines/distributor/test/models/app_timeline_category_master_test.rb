# typed: false
# == Schema Information
#
# Table name: app_timeline_category_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_app_timeline_category_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_app_timeline_category_masters_parent  (parent_id => app_timeline_category_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class AppTimelineCategoryMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "has correct constants" do
    assert_equal 0, AppTimelineCategoryMaster::NOTHING
    assert_equal 1, AppTimelineCategoryMaster::LEGACY_NOTHING
  end

  test "can load nothing status from db" do
    status = AppTimelineCategoryMaster.find(AppTimelineCategoryMaster::NOTHING)

    assert_equal 0, status.id
  end

  test "treeable class is defined" do
    assert_equal AppTimelineCategoryMaster, treeable_class
  end

  private

  def treeable_class
    AppTimelineCategoryMaster
  end
end
