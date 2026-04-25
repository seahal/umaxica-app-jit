# typed: false
# == Schema Information
#
# Table name: app_timeline_tag_masters
# Database name: publication
#
#  id        :bigint           not null, primary key
#  parent_id :bigint           not null
#
# Indexes
#
#  index_app_timeline_tag_masters_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_app_timeline_tag_masters_parent  (parent_id => app_timeline_tag_masters.id)
#

# frozen_string_literal: true

require "test_helper"

class AppTimelineTagMasterTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "treeable class is defined" do
    assert_equal AppTimelineTagMaster, treeable_class
  end

  private

  def treeable_class
    AppTimelineTagMaster
  end
end
